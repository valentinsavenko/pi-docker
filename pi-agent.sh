#!/bin/bash

# Get the directory where THIS script is stored
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONTAINER_NAME="pi-agent"
IMAGE_NAME="pi-agent:root"
DOCKERFILE="$SCRIPT_DIR/Dockerfile"
HASH_FILE="$SCRIPT_DIR/.dockerfile_hash"

# 1. Checksum logic (Cross-platform)
if [ -f "$DOCKERFILE" ]; then
    if command -v md5sum >/dev/null 2>&1; then
        CURRENT_HASH=$(md5sum "$DOCKERFILE" | cut -d' ' -f1)
    else
        CURRENT_HASH=$(md5 -q "$DOCKERFILE")
    fi
else
    echo " Error: Dockerfile not found at $DOCKERFILE"
    exit 1
fi

# 2. Check for changes
if [ -f "$HASH_FILE" ]; then
    OLD_HASH=$(cat "$HASH_FILE")
else
    OLD_HASH=""
fi

if [ "$CURRENT_HASH" != "$OLD_HASH" ]; then
    echo "--- Change detected in $DOCKERFILE. Rebuilding... ---"
    
    # Force remove old container to free up the name
    if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
        docker rm -f "$CONTAINER_NAME" > /dev/null
    fi

    # Build using the script's directory as context
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

    if [ $? -eq 0 ]; then
        echo "$CURRENT_HASH" > "$HASH_FILE"
        docker image prune -f
    else
        echo " Build failed. Keeping old version."
        exit 1
    fi
fi

# 3. Execution Logic
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "--- Joining running agent... ---"
    docker exec -it "$CONTAINER_NAME" /bin/bash || docker exec -it "$CONTAINER_NAME" /bin/sh

elif [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "--- Restarting existing agent... ---"
    docker start -ai "$CONTAINER_NAME"

else
    echo "--- Creating fresh agent... ---"
    docker run -it \
      -v "$(pwd):/workspace" \
      -v "${HOME}/.pi:/root/.pi" \
      -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}" \
      --name "$CONTAINER_NAME" \
      "$IMAGE_NAME" /bin/bash
fi