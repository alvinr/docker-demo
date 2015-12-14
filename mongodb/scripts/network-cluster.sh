#!/bin/bash

NODE=$1

if [ "$NODE" == "" ]
then
  NODE="swarm-0"
fi

docker-machine ssh $NODE "docker service detach mongodb_mongodb_1 mongodb_mongodb_1.multihost"
docker-machine ssh $NODE "docker service detach prod_mongodb_1 prod_mongodb_1.multihost"
docker-machine ssh $NODE "docker service attach prod_mongodb_1 mongodb_mongodb_1.multihost"
docker-machine ssh $NODE "docker service attach mongodb_mongodb_1 prod_mongodb_1.multihost"