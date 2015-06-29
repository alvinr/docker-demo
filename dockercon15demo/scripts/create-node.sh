#!/bin/bash
NAME=$1
TOKEN=$2
IMAGE=$3
CREATE_OPTIONS=$4
DAEMON_OPTIONS=$5

echo "creating $NAME"

docker-machine create -d vmwarefusion --vmwarefusion-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc5/boot2docker.iso --swarm --swarm-discovery=token://$TOKEN --swarm-image=$IMAGE $CREATE_OPTIONS $NAME || :
scripts/install-docker.sh $NAME "$DAEMON_OPTIONS --default-network=overlay:multihost --label=com.docker.network.driver.overlay.bind_interface=eth0"
