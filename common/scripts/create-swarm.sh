#!/bin/bash
DRIVER=vmwarefusion
SWARM_SIZE=3

if [ "$DRIVER" == "vmwarefusion" ]
then
#  B2D_OPT="--vmwarefusion-boot2docker-url=$B2D_URL"
  B2D_OPT=""
  ENGINE_OPT="--engine-opt 'experimental'"
else
  B2D_OPT=""
  ENGINE_OPT="--engine-opt 'experimental' --engine-install-url=$ENGINE_URL"
fi

# Create the rest of the machines in the swarm cluster  

if [ ! -x "$(which parallel)" ]
then
    for i in `seq 0 $SWARM_SIZE`
    do
      docker-machine -D create \
        -d $DRIVER \
        $ENGINE_OPT \
        $B2D_OPT \
        swarm-$i
    done
else
  seq 0 $SWARM_SIZE | parallel docker-machine -D create \
                        -d $DRIVER \
                        $ENGINE_OPT \
                        $B2D_OPT \
                        swarm-{}
fi

# Initialize Swarm-0 as Manager
docker $(docker-machine config swarm-0) swarm init --listen-addr $(docker-machine ip swarm-0):2377
TOKEN=`docker-machine ssh swarm-0 docker swarm join-token --quiet worker`

# Initialize Swarm-1 through Swarm-n as Workers
for i in `seq 1 $SWARM_SIZE`; do docker $(docker-machine config swarm-$i) swarm join --token $TOKEN $(docker-machine ip swarm-0):2377; done
