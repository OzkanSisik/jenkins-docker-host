#!/bin/bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Convenience script to (re)start Jenkins with the correct Docker socket GID
# -----------------------------------------------------------------------------
# 1. Detect the host-specific GID of the Docker socket (macOS / Linux / CI).
# 2. Persist it into a .env file so docker-compose picks it up automatically.
# 3. Rebuild the Jenkins image with --build-arg DOCKER_GID=<gid>.
# 4. Start the stack.
# -----------------------------------------------------------------------------

echo "🔍 Detecting Docker socket GID..."

# Step 1 – create/update .env with DOCKER_GID and export the variable in this shell
./detect-docker-gid.sh
source .env

# Ensure the variable is exported so that docker-compose can access it
export DOCKER_GID

echo "📦 Using DOCKER_GID=$DOCKER_GID"

# Step 2 – bring down any existing stack (ignore errors if not running)
echo "🛑 Stopping existing Jenkins containers (if any) …"
docker-compose down || true

# Step 3 – rebuild the image with the correct GID
echo "🏗️  Building Jenkins image …"
docker-compose build --pull

# Step 4 – start everything
echo "🚀 Starting Jenkins …"
docker-compose up -d

echo "✅ Jenkins is up! Access it at http://localhost:8080"
echo "ℹ️  Inside the container, user 'jenkins' will belong to group docker-host (gid $DOCKER_GID)" 