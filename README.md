# jetson-thor-comfyui-docker
This is a repository to make ComfyUI work on the Jetson Thor. It builds the required packages and library and installs ComfyUI into the container. It also attaches several volumes so that you can download your models, custom_nodes, outputs and inputs.

## Build
If you want to use the bleeding edge development version of the Docker image, you can also clone the repository and build the image yourself:
```
git clone git@github.com:techComOperator/jetson-thor-comfyui-docker.git
cd jetson-thor-comfyui-docker
docker build --tag jetson-thor-comfyui:latest .


## Stop
docker stop jetson-thor-comfyui:latest
docker rm jetson-thor-comfyui:latest

## Run
export COMFYUI_MODEL_FOLDER=""
export COMFYUI_CUSTOM_NODES_FOLDER=""
export COMFYUI_OUTPUT_FOLDER=""
export COMFYUI_INPUT_FOLDER=""
export COMFYUI_EXTERNAL_PORT=8188
docker run --runtime=nvidia --detach --restart unless-stopped \
    --env USER_UID="$(id -u)" \
    --env USER_GID="$(id -g)" \
    --volume "$(COMFYUI_MODEL_FOLDER):/home/comfyui-user/comfy/ComfyUI/models:rw" \
    --volume "$(COMFYUI_CUSTOM_NODES_FOLDER):/home/comfyui-user/comfy/ComfyUI/custom_nodes:rw" \
    --volume "$(COMFYUI_OUTPUT_FOLDER):/home/comfyui-user/comfy/ComfyUI/output:rw" \
    --volume "$(COMFYUI_INPUT_FOLDER):/home/comfyui-user/comfy/ComfyUI/input:rw" \
    --gpus all -p $(COMFYUI_EXTERNAL_PORT):8188 -it jetson-thor-comfyui:latest