#!/usr/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <FOLDING_ID> <PARENT_FOLDER> <OPERATION>"
    exit 1
else
    FOLDING_ID="$1"
    PARENT_FOLDER="$2"
    OPERATION="$3"
fi


get_diagnostics() {
    python --version

    # get driver version
    [[ -f "/proc/driver/nvidia/version" ]] && cat "/proc/driver/nvidia/version"

    # get graphics card and driver info
    command -v nvidia-smi &> /dev/null && nvidia-smi
}
get_diagnostics


BUCKET_NAME="biomodal-structural-bioinformatics"
MOUNTED_BUCKET_FOLDING_DIRECTORY="/gcs/${BUCKET_NAME}/vertex_runs/${PARENT_FOLDER}_input/${FOLDING_ID}"
MOUNTED_BUCKET_OUTPUT_DIRECTORY="/gcs/${BUCKET_NAME}/vertex_runs/${PARENT_FOLDER}_output/${FOLDING_ID}"
mkdir --verbose --parents "$MOUNTED_BUCKET_OUTPUT_DIRECTORY"

# create the local input directory
LOCAL_INPUT_DIRECTORY="/data/vertex_runs/${PARENT_FOLDER}_input/$FOLDING_ID"
mkdir --verbose --parents "$LOCAL_INPUT_DIRECTORY"
cp --recursive --verbose "$MOUNTED_BUCKET_FOLDING_DIRECTORY/"* "$LOCAL_INPUT_DIRECTORY"

# create the folding output directory
FOLDING_DIRECTORY="/data/vertex_runs/${PARENT_FOLDER}_output/$FOLDING_ID"
mkdir --verbose --parents "$FOLDING_DIRECTORY"

source "/app/conda/etc/profile.d/conda.sh" && conda activate "/app/boltz_conda"

# get number of gpus 
ngpus=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
echo "Number of GPUs available: $ngpus"

if [[ $OPERATION == "affinity" ]]; then
    echo "Running affinity prediction for $FOLDING_ID"
    boltz predict \
        $LOCAL_INPUT_DIRECTORY \
        --use_msa_server \
        --recycling_steps 8 \
        --diffusion_samples 20 \
        --diffusion_samples_affinity 10 \
        --sampling_steps 400 \
        --sampling_steps_affinity 400 \
        --use_potentials \
        --devices $ngpus \
        --max_parallel_samples 1 \
        --num_workers $ngpus \
        --cache "/app/.boltz" \
        --out_dir "$FOLDING_DIRECTORY"

elif [[ $OPERATION == "generate_replicate_examples" ]]; then
    echo "Running many folds prediction for $FOLDING_ID"
    boltz predict \
        $LOCAL_INPUT_DIRECTORY \
        --use_msa_server \
        --recycling_steps 8 \
        --diffusion_samples 20 \
        --sampling_steps 400 \
        --use_potentials \
        --devices $ngpus \
        --max_parallel_samples 1 \
        --num_workers $ngpus \
        --cache "/app/.boltz" \
        --out_dir "$FOLDING_DIRECTORY" \
        --multiple_fold 20

fi
# save folding output files
cp --recursive $FOLDING_DIRECTORY/boltz_results*/predictions "$MOUNTED_BUCKET_OUTPUT_DIRECTORY"
