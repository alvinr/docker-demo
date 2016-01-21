#!/bin/bash
NAME=$1

if [ "$NAME" == "" ]
then
   NAME="blog"
fi

docker-machine rm -f $(docker-machine ls -q | grep $NAME)