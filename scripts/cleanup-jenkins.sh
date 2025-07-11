#!/bin/bash

echo "Cleaning up Jenkins CI infrastructure..."

cd ~/jenkins-infra

# Stop and remove containers
docker-compose down

# Remove volumes (WARNING: This will delete all Jenkins data)
read -p "Do you want to delete all Jenkins data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume rm jenkins-infra_jenkins_home jenkins-infra_jenkins_data 2>/dev/null || true
    echo "Jenkins data deleted"
else
    echo "Jenkins data preserved"
fi

echo "Cleanup completed"
