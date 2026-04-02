
# Docker Monitoring Service
This service reports when docker containers are created, started, stopped, or removed

First create the log stream in AWS CloudWatch. Use the `/docker/events` group.

```shell
aws logs create-log-stream --log-group-name /docker/events --log-stream-name <event stream name>
```

Then install the service with the following command:

Make sure to replace `<event stream name>` with the name of the log stream you created in the previous step.
```shell
bash <(curl -fsSL https://raw.githubusercontent.com/Wire-Me/wireme-infra-scripts/refs/heads/main/docker/create-docker-monitor.sh) <event stream name>
```