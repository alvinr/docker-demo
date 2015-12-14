#!/bin/bash
NAME=$1
DRIVER=$2
URL=$3

if [ "$NAME" == "" ]
then
  NAME="dev"
fi

if [ "$DRIVER" == "" ]
then
  DRIVER="vmwarefusion"
fi

if [ "$URL" == "" ]
then
  URL="https://get.docker.com/"
fi

if docker-machine ls | grep -q "$NAME"
then
  echo "$NAME engine already created"
 else 
  docker-machine create -d $DRIVER --engine-install-url $URL $NAME
  scripts/install-docker.sh $NAME
fi
