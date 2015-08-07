#!/bin/bash
NAME=$1
TOKEN=$2
IMAGE=$3
CREATE_OPTIONS=$4
DAEMON_OPTIONS=$5
DRIVER=$6

echo "creating $NAME"

if [ "$DRIVER" == "" ]
then
  DRIVER="vmwarefusion"
fi

if docker-machine ls | grep -q "$NAME"
  then 
    echo "$NAME already created"
  else 
    echo docker-machine create -d $DRIVER --swarm --swarm-discovery=token://$TOKEN --swarm-image="$IMAGE" $CREATE_OPTIONS $NAME || true
    docker-machine create -d $DRIVER --swarm --swarm-discovery=token://$TOKEN --swarm-image="$IMAGE" $CREATE_OPTIONS $NAME || true
fi

version=$(docker-machine ssh $NAME "uname -r")
maj=`echo $version | cut -d"." -f 1`
min=`echo $version | cut -d"." -f 2`

if [ "$maj" == "3" ] && [ "$min" -lt "15" ]
then
  echo Need to upgrade Linux kernel for $NAME
  docker-machine ssh $NAME 'sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install linux-image-extra-3.16.0-43-generic'
fi

echo "installing Docker..."
scripts/install-docker.sh $NAME "$DAEMON_OPTIONS --default-network=overlay:multihost --label=com.docker.network.driver.overlay.bind_interface=eth0"