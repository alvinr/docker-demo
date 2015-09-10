#!/bin/bash
NAME=$1
TOKEN=$2
IMAGE=$3
CREATE_OPTIONS=$4
DAEMON_OPTIONS=$5
DRIVER=$6

URL="http://experimental.docker.com"

echo "creating $NAME"

if [ "$DRIVER" == "" ]
then
  DRIVER="vmwarefusion"
fi

if docker-machine ls | grep -q "$NAME"
  then 
    echo "$NAME already created"
  else 
#    docker-machine create -d $DRIVER --swarm --swarm-discovery=token://$TOKEN --swarm-image="$IMAGE" $CREATE_OPTIONS --engine-install-url $URL $NAME || true
# Because compose does not add "--net=bridge" to the container startup for Swarm, the above line cannot be used. Instead
# the folloiwnf runs the swarm containers manually with the right config
    docker-machine create -d $DRIVER \
        --engine-install-url="$URL" \
        --engine-opt="default-network=overlay:multihost" \
        --engine-label="com.docker.network.driver.overlay.bind_interface=eth0" \
        $DAEMON_OPTIONS \
        $NAME || true
fi

echo Start Swarm container

if [ "$CREATE_OPTIONS" == "--swarm-master" ]
then
docker $(docker-machine config $NAME) run -d \
    --restart="always" \
    --net="bridge" \
    -p "3376:3376" \
    -v "/etc/docker:/etc/docker" \
    --name="swarm-master" \
    $IMAGE manage \
        --tlsverify \
        --tlscacert="/etc/docker/ca.pem" \
        --tlscert="/etc/docker/server.pem" \
        --tlskey="/etc/docker/server-key.pem" \
        -H "tcp://0.0.0.0:3376" \
        --strategy spread \
        "token://$TOKEN"
fi

docker $(docker-machine config $NAME) run -d \
    --restart="always" \
    --net="bridge" \
    --name="swarm-agent" \
    $IMAGE join \
        --addr "$(docker-machine ip $NAME):2376" \
        "token://$TOKEN"

version=$(docker-machine ssh $NAME "uname -r")
maj=`echo $version | cut -d"." -f 1`
min=`echo $version | cut -d"." -f 2`

if [ "$maj" == "3" ] && [ "$min" -lt "15" ]
then
  echo Need to upgrade Linux kernel for $NAME
  docker-machine ssh $NAME 'sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install linux-image-extra-3.16.0-43-generic'
fi

echo "installing Docker..."
#scripts/install-docker.sh $NAME "$DAEMON_OPTIONS --default-network=overlay:multihost --label=com.docker.network.driver.overlay.bind_interface=eth0"


if [ "$maj" == "3" ] && [ "$min" -lt "15" ]
then
  docker-machine ssh $NAME "sudo reboot"
fi