#!/bin/bash

echo "Creating Docker Monitor script"
bash <(curl -fsSL https://raw.githubusercontent.com/Wire-Me/wireme-infra-scripts/refs/heads/main/docker/create-docker-monitor-script.sh)

echo "Creating Docker Monitor service"
echo "Make sure to provide log stream name as an argument"
bash <(curl -fsSL https://raw.githubusercontent.com/Wire-Me/wireme-infra-scripts/refs/heads/main/docker/create-docker-monitor-service.sh)

