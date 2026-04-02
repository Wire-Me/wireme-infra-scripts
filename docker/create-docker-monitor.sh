#!/bin/bash

set -euo pipefail

LOG_STREAM_NAME="${1:-}"

if [[ -z "$LOG_STREAM_NAME" || "$LOG_STREAM_NAME" == "<LOG_STREAM_NAME>" ]]; then
  echo "Error: You must provide a log stream name as the first argument." >&2
  echo "Usage: bash setup.sh <your-log-stream-name>" >&2
  exit 1
fi

echo "Creating Docker Monitor script"
bash <(curl -fsSL https://raw.githubusercontent.com/Wire-Me/wireme-infra-scripts/refs/heads/main/docker/create-docker-monitor-script.sh)

echo "Creating Docker Monitor service"
echo "Make sure to provide log stream name as an argument"
bash <(curl -fsSL https://raw.githubusercontent.com/Wire-Me/wireme-infra-scripts/refs/heads/main/docker/create-docker-monitor-service.sh) "$LOG_STREAM_NAME"

