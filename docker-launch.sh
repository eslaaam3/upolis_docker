#!/bin/bash

container_name=$1
image_name=$2
# ros2_domain_id=$3
# ros2_discovery_ip=$4

echo $container_name
echo $image_name
# echo $ros2_domain_id
# echo $ros2_discovery_ip

#exit

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi
xhost +local:docker

# ========================================== #
#               DOCKER INSTALLATION          #
# ========================================== #

# ========== Installation ==========
# sudo apt-get update -y
# sudo apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
# # ========== Post-installation ==========
# sudo groupadd docker
# sudo usermod -aG docker $USERNAME
# newgrp docker

# # ========== NVIDIA Container toolkit ==========
# curl https://get.docker.com | sh && sudo systemctl --now enable docker
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#       && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#       && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
#             sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#             sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
# sudo apt-get update -y
# sudo apt-get install -y nvidia-docker2 -y
# sudo systemctl restart docker


# ============================================ #
#           SETTING UP USER WORKSPACE          #
# ============================================ #

timestamp=`date +"%Y%m%d_%H%M%S"`

if [[ ! -d ~/${container_name}_workspace ]]; then
    echo "Creating directory ${container_name}_workspace_${timestamp} /home/$USERNAME/Docker/${container_name}_workspace_${timestamp}"
    mkdir -p ~/Docker/${container_name}_workspace_${timestamp}
fi


# ============================================ #
#           RUNNING DOCKER CONTAINER           #
# ============================================ #

# # interactive, terminal, attached to STDIN/OUT/ERR
# -ita \                
# # Add 'all' gpus to the container
# --gpus all \                
# # Set terminal colors
# -e "TERM=xterm-256color" \
# # Set display environment variable to copy host's value
# --env="DISPLAY=$DISPLAY" \
# # Set network interface to be the host so that the container can access all
# --net=host \
# # network interfaces exactly as the host
# --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
# # GUI Settings
# --env="QT_X11_NO_MITSHM=1" \
# # Mount X11 server directory to be able to use GUI inside the container
# --env="XAUTHORITY=$XAUTH" \
# # I don't know what is this !!!
# --volume="$XAUTH:$XAUTH" \
# # Use NVIDIA runtime in the container
# --runtime=nvidia \
# # Pass container name and image to use through terminal args
# --name "$container_name" "$image_name"
# --mount type=bind,source=/tmp,target=/usr 
# -v /tmp:/usr


# ================================================ #
#           ENVIRONMENT VARIABLES - ROS2           #
# ================================================ #

docker run \
    -it \
    --gpus all \
    -e "TERM=xterm-256color" \
    --env="DISPLAY=$DISPLAY" \
    --env="ROS_DOMAIN_ID=$ROS_DOMAIN_ID" \
    --env="ROS_DISCOVERY_SERVER=$ROS_DISCOVERY_SERVER" \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v test:/tmp/:rw \
    --mount type=bind,source=/home/$USERNAME/Docker/${container_name}_workspace_${timestamp},target=/home/upolis/workspace \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --runtime=nvidia \
    --name "$container_name" "$image_name"