#!/bin/bash
# Once compose support launch on the bridge network, this command can be used
# eval "$(docker-machine env --swarm swarm-0)"

export DOCKER_HOST=tcp://"$(docker-machine ip swarm-0):3376"
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH="$HOME/.docker/machine/machines/swarm-0"

docker-compose stop
docker-compose rm -f
