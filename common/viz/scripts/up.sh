#!/bin/bash
set -e

SWARM_MACHINE_NAME=$1

CERT_PATH=~/.docker/machine/machines/$SWARM_MACHINE_NAME
export SWARM_CA=$(cat $CERT_PATH/ca.pem)
export SWARM_CERT=$(cat $CERT_PATH/cert.pem)
export SWARM_KEY=$(cat $CERT_PATH/key.pem)
export SWARM_HOST=tcp://$(docker-machine ip $SWARM_MACHINE_NAME):3376

docker-compose build
exec docker-compose up -d
