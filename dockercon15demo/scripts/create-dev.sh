#!/bin/bash
NAME=$1

if [ "$NAME" == "" ]
then
  NAME="dev "
fi

if docker-machine ls | grep -q "$NAME"
then
  echo "$NAME engine already created"
 else 
  docker-machine create -d vmwarefusion $NAME
  docker-machine ssh $NAME 'sudo sh -c "/etc/init.d/docker stop; curl https://experimental.docker.com/builds/Linux/x86_64/docker-latest > /usr/bin/docker; chmod +x /usr/bin/docker; /etc/init.d/docker start'
  scripts/install-docker.sh $NAME
fi