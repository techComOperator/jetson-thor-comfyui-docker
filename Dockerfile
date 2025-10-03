FROM ubuntu:24.04

# Update and upgrade packages.
RUN apt-get update -y && \
    apt upgrade -y && \
    apt-get install -y wget curl git vim pipx libgl1-mesa-dev

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb

RUN apt update && \
 apt -y install cuda-toolkit-13-0 cudnn

# Create non-root user for added security.
ARG USERNAME=comfyui-user
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash -m $USERNAME

WORKDIR /home/comfyui-user

USER $USERNAME

RUN pipx ensurepath

RUN pipx install virtualenv && \
    echo "export PATH=/home/$USERNAME/.local/bin:/home/$USERNAME/comfyui/bin:$PATH" >> ~/.bashrc && \
    echo ". comfyui/bin/activate" >> ~/.bashrc


RUN /home/$USERNAME/.local/bin/virtualenv comfyui
# && . comfyui/bin/activate
SHELL ["/bin/bash", "--login", "-c"]
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130 && \
    pip install comfy-cli && \
    comfy-cli --skip-prompt install --nvidia

EXPOSE 8188

CMD ["python", "/home/comfyui-user/comfy/ComfyUI/main.py", "--listen", "0.0.0.0"]