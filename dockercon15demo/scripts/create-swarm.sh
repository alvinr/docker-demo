#!/bin/bash
SWARM_SIZE=$1

if [ "$SWARM_SIZE" == "" ] 
then
  SWARM_SIZE=4
fi

SWARM_NAME=swarm
TOKEN=$(docker run swarm create)
IMAGE="swarm:0.3.0"

if docker-machine ls | grep -q "$SWARM_NAME-consul"
  then 
    echo "consul already created"
  else 
    scripts/create-consul.sh $SWARM_NAME
fi
CONSUL_IP=$(docker-machine ip $SWARM_NAME-consul)

scripts/create-node.sh $SWARM_NAME-0 $TOKEN $IMAGE "--swarm-master" "--kv-store=consul:$CONSUL_IP:8500"

MASTER_IP=$(docker-machine ip $SWARM_NAME-0)

for i in `seq 1 $SWARM_SIZE`
do
#  parallel "script/create-node $SWARM_NAME-{} $TOKEN $IMAGE '' '--kv-store=consul:$CONSUL_IP:8500 --label com.docker.network.driver.overlay.neighbor_ip=$MASTER_IP'"
  scripts/create-node.sh $SWARM_NAME-$i $TOKEN $IMAGE "" "--kv-store=consul:$CONSUL_IP:8500 --label com.docker.network.driver.overlay.neighbor_ip=$MASTER_IP"
done