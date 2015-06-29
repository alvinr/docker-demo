#!/bin/bash
NAME=$1
ENGINE="$NAME-consul"

if [ "$ENGINE" == "" ]
then
  ENGINE=$NAME-consul
fi

if docker-machine ls | grep -q "$ENGINE"
then
  echo "consul engine already created"
 else
   docker-machine create -d vmwarefusion --vmwarefusion-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc5/boot2docker.iso $ENGINE
   scripts/install-docker.sh $ENGINE
fi

eval "$(docker-machine env $ENGINE)"

if docker ps | grep -q "$ENGINE"
then
  echo "consul already running"
else
  docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h $NAME-consul --name $NAME-consul progrium/consul -server -bootstrap
fi

