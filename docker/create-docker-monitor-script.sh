sudo tee /usr/local/bin/docker-monitor.sh > /dev/null <<'EOF'
#!/bin/bash

LOG_GROUP="/docker/events"
LOG_STREAM="${1:?Usage: $0 <log-stream-name>}"
SEQUENCE_TOKEN=""

send_to_cloudwatch() {
  local message="$1"
  local timestamp=$(date +%s000)

  if [ -z "$SEQUENCE_TOKEN" ]; then
    RESULT=$(aws logs put-log-events \
      --log-group-name "$LOG_GROUP" \
      --log-stream-name "$LOG_STREAM" \
      --log-events "[{\"timestamp\": $timestamp, \"message\": \"$message\"}]" \
      2>&1)
  else
    RESULT=$(aws logs put-log-events \
      --log-group-name "$LOG_GROUP" \
      --log-stream-name "$LOG_STREAM" \
      --sequence-token "$SEQUENCE_TOKEN" \
      --log-events "[{\"timestamp\": $timestamp, \"message\": \"$message\"}]" \
      2>&1)
  fi

  SEQUENCE_TOKEN=$(echo "$RESULT" | jq -r '.nextSequenceToken // empty')
}

echo "Starting Docker event monitor..."
echo "Log Stream: $LOG_STREAM"
echo "Log Group: $LOG_GROUP"

while true; do
  sudo docker events \
    --filter 'type=container' \
    --format '{{json .}}' | while read event; do

    STATUS=$(echo "$event" | jq -r '.status')
    CONTAINER=$(echo "$event" | jq -r '.Actor.Attributes.name')
    IMAGE=$(echo "$event" | jq -r '.Actor.Attributes.image')

    MESSAGE="container=$CONTAINER image=$IMAGE status=$STATUS"
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $MESSAGE"

    send_to_cloudwatch "$MESSAGE"
  done

  echo "docker events exited, restarting in 1s..."
  sleep 1
done
EOF

sudo chmod +x /usr/local/bin/docker-monitor.sh
echo "Created /usr/local/bin/docker-monitor.sh"