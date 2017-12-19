#!/bin/bash
# Once compose support launch on the bridge network, this command can be used
# eval "$(docker-machine env --swarm swarm-0)"

# export SWARM_HOST=tcp://"$(docker-machine ip swarm-0):3376"
# export DOCKER_HOST=tcp://"$(docker-machine ip swarm-0):3376"
# export DOCKER_TLS_VERIFY=1
# export DOCKER_CERT_PATH="$HOME/.docker/machine/machines/swarm-0"

eval $(docker-machine env swarm-0)
export PS1="\h:~/prod-app$ "
