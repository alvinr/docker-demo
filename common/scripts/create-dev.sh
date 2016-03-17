#!/bin/bash
ENGINE_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.10.3
B2D_URL=https://github.com/tianon/boot2docker-legacy/releases/download/v1.10.0-rc1/boot2docker.iso
DRIVER=vmwarefusion
NAME=dev

if [ "$DRIVER" == "vmwarefusion" ]
then
#  B2D_OPT="--vmwarefusion-boot2docker-url=$B2D_URL"
  B2D_OPT=""
  ENGINE_OPT=""
else
  B2D_OPT=""
  ENGINE_OPT="--engine-install-url=$ENGINE_URL"
fi

if docker-machine ls | grep -q "$NAME"
then
  echo "$NAME engine already created"
else 
  docker-machine create \
    -d $DRIVER \
    $ENGINE_OPT \
    $B2D_OPT \
    $NAME 
fi
