#!/bin/bash
MODE=$1
NAME=$2

if [ "$MODE" == "" ]
then
  MODE="restart"
fi

if [ "$NAME" == "" ]
then
   NAME="swarm"
fi

for NODE in `docker-machine ls -q | grep -E "$NAME-[0-9]+"`
do
    echo $MODE Docker on $NODE
    lsb_dist=""
    if [ ! -x $(docker-machine ssh $NODE "which lsb_release") ]
    then
      lsb_dist=$(docker-machine ssh $NODE "lsb_release -si" | cut -d" " -f 1)
    fi

    if [ "$lsb_dist" == "Ubuntu" ]
    then
      docker-machine ssh $NODE "sudo service docker $MODE"
    else
      docker-machine ssh $NODE "sudo /etc/init.d/docker $MODE"
    fi 
done