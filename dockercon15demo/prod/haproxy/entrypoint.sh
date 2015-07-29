#!/bin/sh

DEFAULTOPTIONS="--swarm-url=$DOCKER_HOST --swarm-tls-ca-cert=/etc/docker/ca.pem --swarm-tls-cert=/etc/docker/server.pem --swarm-tls-key=/etc/docker/server-key.pem --plugin haproxy start"

exec /usr/local/bin/interlock ${1:-$DEFAULTOPTIONS}
