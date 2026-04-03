#!/bin/bash

set -euo pipefail

CONTAINER_NAME="${1:-}"
METRIC_NAME="${2:-}"

if [[ -z "$CONTAINER_NAME" ]]; then
  echo "Error: You must provide a log stream name as the first argument." >&2
  exit 1
fi

if [[ -z "$METRIC_NAME" ]]; then
  echo "Error: You must provide a metric name as the second argument." >&2
  exit 1
fi

aws logs put-metric-filter \
  --log-group-name "/docker/events" \
  --filter-name "$CONTAINER_NAME-kill-start" \
  --filter-pattern "[container=\"container=$CONTAINER_NAME\", image, status=\"status=kill\" || status=\"status=start\"]" \
  --metric-transformations \
    metricName="$METRIC_NAME",metricNamespace=WireMe/ECS,metricValue=1

aws sns create-topic --name "wireme-$CONTAINER_NAME-alerts"

aws sns subscribe \
  --topic-arn "arn:aws:sns:us-east-1:618002989681:wireme-$CONTAINER_NAME-alerts" \
  --protocol email \
  --notification-endpoint ian@wireme.io

aws cloudwatch put-metric-alarm \
  --alarm-name "$CONTAINER_NAME-kill-start-alarm" \
  --metric-name "$METRIC_NAME" \
  --namespace WireMe/ECS \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions "arn:aws:sns:us-east-1:618002989681:wireme-$CONTAINER_NAME-alerts" \
  --treat-missing-data notBreaching