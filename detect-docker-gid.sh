#!/bin/bash

set -euo pipefail

echo "🔍 Detecting Docker socket GID..."

# Function to detect Docker socket GID
detect_docker_gid() {
    local socket_paths=(
        "/var/run/docker.sock"                    # Standard Linux path
        "$HOME/.docker/run/docker.sock"          # macOS Docker Desktop
        "/Users/$USER/.docker/run/docker.sock"   # macOS alternative
    )
    
    for socket_path in "${socket_paths[@]}"; do
        if [[ -S "$socket_path" ]]; then
            echo "✅ Found Docker socket at: $socket_path"
            
            # Get the GID of the socket file
            if [[ "$OSTYPE" == "darwin"* ]]; then
                DOCKER_GID=$(stat -L -f %g "$socket_path")
            else
                DOCKER_GID=$(stat -L -c %g "$socket_path")
            fi
            
            echo "📋 Docker socket GID: $DOCKER_GID"
            
            export DOCKER_GID

            echo "DOCKER_GID=$DOCKER_GID" > .env
            echo "✅ Created .env file with DOCKER_GID=$DOCKER_GID"
            
            return 0
        fi
    done
    
    echo "❌ Docker socket not found. Please ensure Docker is running."
    exit 1
}

# Run detection
detect_docker_gid

echo "🚀 You can now run: docker-compose up -d" 