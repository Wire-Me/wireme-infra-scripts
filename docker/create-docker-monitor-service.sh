#!/bin/bash
set -euo pipefail

LOG_STREAM_NAME="${1:-}"

if [[ -z "$LOG_STREAM_NAME" || "$LOG_STREAM_NAME" == "<LOG_STREAM_NAME>" ]]; then
  echo "Error: You must provide a log stream name as the first argument." >&2
  echo "Usage: bash setup.sh <your-log-stream-name>" >&2
  exit 1
fi

sudo tee /etc/systemd/system/docker-monitor.service > /dev/null <<EOF
[Unit]
Description=Docker Event Monitor → CloudWatch
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/docker-monitor.sh ${LOG_STREAM_NAME}
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Install jq
sudo apt-get update
sudo apt-get install -y jq

sudo systemctl daemon-reload
sudo systemctl enable docker-monitor
sudo systemctl start docker-monitor

sudo systemctl status docker-monitor
sudo journalctl -u docker-monitor -f