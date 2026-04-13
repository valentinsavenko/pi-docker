#!/bin/bash

CONTAINER_NAME="pi-agent"
IMAGE_NAME="pi-agent:root"

# 1. Check if the container is already running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "--- Joining running agent... ---"
    docker exec -it "$CONTAINER_NAME" /bin/bash || docker exec -it "$CONTAINER_NAME" /bin/sh

# 2. Check if the container exists but is stopped
elif [ "$(docker ps -aq -f status=exited -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "--- Restarting existing agent... ---"
    docker start -ai "$CONTAINER_NAME"

# 3. If it doesn't exist, create it with your specific settings
else
    echo "--- Creating fresh agent... ---"
    docker run -it \
      -v "$(pwd):/workspace" \
      -v "${HOME}/.pi:/root/.pi" \
      -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}" \
      --name "$CONTAINER_NAME" \
      "$IMAGE_NAME" /bin/bash
fi
