#!/bin/bash
ENGINE_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.10.0-rc1
B2D_URL=https://github.com/tianon/boot2docker-legacy/releases/download/v1.10.0-rc1/boot2docker.iso
DRIVER=vmwarefusion

if [ "$DRIVER" == "vmwarefusion" ]
then
  B2D_OPT="--vmwarefusion-boot2docker-url=$B2D_URL"
else
  B2D_OPT=""
fi

ENGINE_OPT="--engine-install-url=$ENGINE_URL"

docker-machine create \
  --driver $DRIVER \
  $ENGINE_OPT \
  $B2D_OPT \
  blog-consul

docker $(docker-machine config blog-consul) run \
        -d \
        --restart=always \
        -p "8500:8500" \
        -h "consul" \
        progrium/consul -server -bootstrap

docker-machine create \
  --driver $DRIVER \
  $ENGINE_OPT \
  $B2D_OPT \
  --swarm \
  --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip blog-consul):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip blog-consul):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  blog-0

docker-machine create \
  --driver $DRIVER \
  $ENGINE_OPT \
  $B2D_OPT \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip blog-consul):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip blog-consul):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  blog-1

  docker $(docker-machine config --swarm blog-0) network create --driver overlay --internal prod
