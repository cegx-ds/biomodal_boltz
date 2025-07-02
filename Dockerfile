FROM us-docker.pkg.dev/deeplearning-platform-release/gcr.io/pytorch-cu124.2-4.py310

WORKDIR /app

# download and install Mambaforge
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p "/app/conda" && \
    rm Miniconda3-latest-Linux-x86_64.sh

# set environment variables
ENV PATH="/app/conda/condabin:${PATH}"

# set up conda environment
SHELL ["/bin/bash", "-c"]
RUN source "/app/conda/etc/profile.d/conda.sh" && \
    conda update -n base conda -y && \
    conda create -y -p "/app/boltz_conda" -c conda-forge -c bioconda \
    git python=3.11

COPY . /app

RUN source "/app/conda/etc/profile.d/conda.sh" && \
    conda activate "/app/boltz_conda" && \
    pip install . && \
    conda clean -afy

ENTRYPOINT ["bash", "/app/run_job.sh"]