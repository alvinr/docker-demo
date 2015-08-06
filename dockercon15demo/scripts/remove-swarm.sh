#!/bin/bash
NAME=$1

if [ "$NAME" == "" ]
then
   NAME="swarm"
fi

docker-machine rm -f $(docker-machine ls -q | grep $NAME)