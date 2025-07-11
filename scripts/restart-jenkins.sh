#!/bin/bash

echo "Restarting Jenkins CI infrastructure..."

cd ~/jenkins-infra
docker-compose restart

echo "Jenkins restarted"
