#!/bin/bash

#./scripts/reset_networks

for FILE in "docker-compose.yml"; do
  docker-compose -f $FILE stop
  docker-compose -f $FILE rm -f
done

for NODE in $(docker-machine ls -q | grep swarm)
do
  docker-machine ssh $NODE "sudo rm -r /data/db/*" 
done
