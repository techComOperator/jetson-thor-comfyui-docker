FROM --platform=arm64 ubuntu:24.04

# Update and upgrade packages.
RUN apt update && \
    apt upgrade

# Create non-root user for added security.
ARG USERNAME=comfyui-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash -m $USERNAME

WORKDIR /home/comfyui-user

# Install Miniconda and Python 3.13
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && \
    chmod +x Miniconda3-latest-Linux-aarch64.sh && \
    ./Miniconda3-latest-Linux-aarch64.sh && \
    conda create -n comfyui python=3.13

# Install CUDA 13 since it's the only one that works with Jetson Thor
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/arm64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get -y install cuda-toolkit-13-0 cuda-compat-13-0 && \
    apt-get install git cudnn python3-libnvinfer python3-libnvinfer-dev tensorrt

# Verify CUDA 13 location.
RUN ls -l /usr/local | grep cuda && \
    ln -s /usr/local/cuda-3.0 /usr/local/cuda && \
    chown $USERNAME: --recursive /comfyui

USER $USERNAME

RUN export PATH=/usr/local/cuda/bin:$PATH && \
    nvcc --version

RUN echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc && \
    echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc && \
    echo 'export CUDA_PATH=/usr/local/cuda' >> ~/.bashrc && \
    source ~/.bashrc

# Activate ComfyUI env via Conda
RUN conda activate comfyui

# Install Pytorch reqs first.
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130 && \
    pip install comfy-cli && \
    comfy-cli install

# Run ComfyUI with an argument that allows you to change port and address.

EXPOSE 8188
CMD ["python","/home/${USERNAME}/ComfyUI/main.py","--listen","0.0.0.0"]
