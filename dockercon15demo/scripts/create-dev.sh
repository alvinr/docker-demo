#!/bin/bash
NAME=$1
DRIVER=$2

if [ "$NAME" == "" ]
then
  NAME="dev"
fi

if [ "$DRIVER" == "" ]
then
  DRIVER="vmwarefusion"
fi

if docker-machine ls | grep -q "$NAME"
then
  echo "$NAME engine already created"
 else 
  docker-machine create -d $DRIVER $NAME
  scripts/install-docker.sh $NAME
fi
