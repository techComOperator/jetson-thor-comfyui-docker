FROM nvidia/cuda:13.0.1-cudnn-devel-ubuntu24.04

# Update and upgrade packages.
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y wget curl git

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/arm64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb

RUN apt update && apt -y upgrade

# Create non-root user for added security.
ARG USERNAME=comfyui-user
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash -m $USERNAME

WORKDIR /home/comfyui-user

USER $USERNAME

# Install Miniconda and Python 3.13
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && \
    chmod +x Miniconda3-latest-Linux-aarch64.sh && \
    SHELL=/bin/bash ./Miniconda3-latest-Linux-aarch64.sh -b && \
    /home/${USERNAME}/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /home/${USERNAME}/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    /home/${USERNAME}/miniconda3/bin/conda create -n comfyui python=3.13

# Set up the environment.
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc && \
    echo "export PATH=/home/${USERNAME}/miniconda3/bin:$PATH" >> ~/.bashrc && \
    echo "export CUDA_HOME=/usr/local/cuda" >> ~/.bashrc && \
    echo "export CUDA_PATH=/usr/local/cuda" >> ~/.bashrc && \
    echo "/home/${USERNAME}/miniconda3/bin/conda activate comfyui" >> ~/.bashrc

SHELL [ "/bin/bash", "-c" ]

# Install Pytorch reqs first.
RUN /home/${USERNAME}/miniconda3/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130 && \
    /home/${USERNAME}/miniconda3/bin/pip install comfy-cli

# Install ComfyUI with NVIDIA
RUN /home/${USERNAME}/miniconda3/bin/comfy-cli --skip-prompt install --nvidia

# Run ComfyUI with an argument that allows you to change port and address.

EXPOSE 8188
CMD ["python","/home/${USERNAME}/ComfyUI/main.py","--listen","0.0.0.0"]
