FROM ubuntu:24.04

# Update and upgrade packages.
RUN apt update && \
    apt upgrade

# Install Miniconda and Python 3.13
RUN 

# Install CUDA 13 since it's the only one that works with Jetson Thor
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/arm64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-13-0 cuda-compat-13
sudo apt-get install cudnn python3-libnvinfer python3-libnvinfer-dev tensorrt

# Verify CUDA 13 location.
ls -l /usr/local | grep cuda
sudo ln -s /usr/local/cuda-12.4 /usr/local/cuda

export PATH=/usr/local/cuda/bin:$PATH
nvcc --version

echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc
echo 'export CUDA_PATH=/usr/local/cuda' >> ~/.bashrc
source ~/.bashrc

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Install Pytorch reqs first.

# Install requirements.

# Run ComfyUI with an argument that allows you to change port and address.

