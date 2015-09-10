#!/bin/bash
NAME=$1
ENGINE="$NAME-consul"
DRIVER=$2

if [ "$NAME" == "" ]
then
  ENGINE=$NAME-consul
fi

if [ "$DRIVER" == "" ]
then
  DRIVER="vmwarefusion"
fi


if docker-machine ls | grep -q "$ENGINE"
then
  echo "consul engine already created"
 else
   docker-machine create -d $DRIVER $ENGINE
   scripts/install-docker.sh $ENGINE
fi

eval "$(docker-machine env $ENGINE)"

if docker ps | grep -q "$ENGINE"
then
  echo "consul already running"
else
  docker run -d --restart=always -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h $NAME-consul --name $NAME-consul progrium/consul -server -bootstrap
fi

