#!/bin/bash
NAME=$1

if [ "$NAME" == "" ]
then
  NAME="dev "
fi

if docker-machine ls | grep -q "$NAME"
then
  docker-machine stop $NAME
  docker-machine rm -f $NAME
fi
