FROM nvidia/cuda:13.0.1-cudnn-runtime-ubuntu24.04

# Create non-root user for added security
ARG USERNAME=comfyui-user
ARG USER_UID=1001
ARG USER_GID=100

# Install system dependencies in a single layer with cleanup
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        git \
        python3 \
        python3-venv \
        python3-pip \
        libgl1-mesa-dev \
        libglib2.0-0 \
        libsm6 \
        libxrender1 \
        libxext6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the user
RUN useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash -m $USERNAME

USER $USERNAME
WORKDIR /home/${USERNAME}

# Set up Python environment and install dependencies
RUN python3 -m venv /home/$USERNAME/venv && \
    . /home/$USERNAME/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip install comfy-cli && \
    comfy --skip-prompt tracking disable && \
    comfy --skip-prompt install --nvidia && \
    pip cache purge

# Set PATH for the user
ENV PATH="/home/$USERNAME/venv/bin:$PATH"

EXPOSE 8188

CMD ["comfy","launch","--", "--listen", "0.0.0.0"]