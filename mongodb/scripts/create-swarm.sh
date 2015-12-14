#!/bin/bash -x
DRIVER=$1
SWARM_SIZE=$2

if [ "$DRIVER" == "" ] 
then
  DRIVER="vmwarefusion"
fi

if [ "$SWARM_SIZE" == "" ] 
then
  SWARM_SIZE=4
fi

SWARM_NAME="swarm"
TOKEN=$(docker run swarm create)
#IMAGE="swarm:0.4.0"
IMAGE="swarm:latest"

if docker-machine ls | grep -q "$SWARM_NAME-consul"
  then 
    echo "consul already created"
  else 
    scripts/create-consul.sh $SWARM_NAME $DRIVER
fi
CONSUL_IP=$(docker-machine ip $SWARM_NAME-consul)

scripts/create-node.sh $SWARM_NAME-0 $TOKEN $IMAGE "--swarm-master" "--cluster-store=consul://$CONSUL_IP:8500" $DRIVER

MASTER_IP=$(docker-machine ip $SWARM_NAME-0)

if [ ! -x "$(which parallel)" ]
then
    for i in `seq 1 $SWARM_SIZE`
    do
      scripts/create-node.sh $SWARM_NAME-$i "$TOKEN" "$IMAGE" "/" "--cluster-store=consul://$CONSUL_IP:8500\ --label=\"com.docker.network.driver.overlay.neighbor_ip=$MASTER_IP\"" $DRIVER
    done
else
    seq $SWARM_SIZE | parallel scripts/create-node.sh $SWARM_NAME-{} "$TOKEN" "$IMAGE" "/" "--cluster-store=consul://$CONSUL_IP:8500\ --label=\"com.docker.network.driver.overlay.neighbor_ip=$MASTER_IP\"" $DRIVER
fi