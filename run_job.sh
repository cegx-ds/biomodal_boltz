#!/usr/bin/bash

if [[ -z "$1" ]]; then
    echo "folding run input argument required"
    exit 1
else
    FOLDING_ID="$1"
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
MOUNTED_BUCKET_FOLDING_DIRECTORY="/gcs/$BUCKET_NAME/vertex_runs/ntDRM2_input/$FOLDING_ID"
MOUNTED_BUCKET_OUTPUT_DIRECTORY="/gcs/$BUCKET_NAME/vertex_runs/ntDRM2_output/$FOLDING_ID"

# create the local input directory
LOCAL_INPUT_DIRECTORY="/data/vertex_runs/ntDRM2_input/$FOLDING_ID"
mkdir --verbose --parents "$LOCAL_INPUT_DIRECTORY"
cp --recursive --verbose "$MOUNTED_BUCKET_FOLDING_DIRECTORY/"* "$LOCAL_INPUT_DIRECTORY"

# create the folding output directory
FOLDING_DIRECTORY="/data/vertex_runs/ntDRM2_output/$FOLDING_ID"
mkdir --verbose --parents "$FOLDING_DIRECTORY"

source "/app/conda/etc/profile.d/conda.sh" && conda activate "/app/boltz_conda"

boltz predict \
    $LOCAL_INPUT_DIRECTORY \
    --use_msa_server \
    --recycling_steps 8 \
    --diffusion_samples 10 \
    --diffusion_samples_affinity 10 \
    --sampling_steps 400 \
    --sampling_steps_affinity 400 \
    --devices 4 \
    --num_workers 4 \
    --cache "/app/.boltz" \
    --out_dir "$FOLDING_DIRECTORY" \

# save folding output files
cp --recursive $FOLDING_DIRECTORY/boltz_results*/predictions "$MOUNTED_BUCKET_OUTPUT_DIRECTORY"