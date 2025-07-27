#!/bin/bash

echo "Starting Jenkins CI infrastructure..."

cd ~/jenkins-infra

# Start Jenkins
docker-compose up -d

echo "Waiting for Jenkins to start..."
sleep 30

# Check if Jenkins is running
if curl -s http://localhost:8080 > /dev/null; then
    echo "SUCCESS: Jenkins is running at http://localhost:8080"
    echo "Use your configured admin credentials to login"
else
    echo "ERROR: Jenkins failed to start"
    docker-compose logs
fi
