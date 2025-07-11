#!/bin/bash

echo "Stopping Jenkins CI infrastructure..."

cd ~/jenkins-infra
docker-compose down

echo "Jenkins stopped"
