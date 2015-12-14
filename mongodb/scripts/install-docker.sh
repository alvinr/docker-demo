#!/bin/bash -x
NAME=$1
DAEMON_ARGS=$2
URL=$3

if [ "$URL" == "" ]
then
  URL="https://experimental.docker.com/builds/Linux/x86_64/docker-latest"
#  URL="https://experimental.docker.com/"
fi

# dockercon15 demo
# URL="https://bfirsh.s3.amazonaws.com/docker-multihost/docker-1.8.0-dev-91fd45c"

lsb_dist=""
if [ ! -x $(docker-machine ssh $NAME "which lsb_release") ]
then
  lsb_dist=$(docker-machine ssh $NAME "lsb_release -si" | cut -d" " -f 1)
fi

_base="$(dirname $0)"

# if [ "$lsb_dist" == "Ubuntu" ]
# then
#     docker-machine ssh $NAME "sudo service docker stop; \
#                               sudo usermod -aG docker \$USER; \
#                               wget -qO- https://experimental.docker.com/ | sudo sh; \
#                               echo 'DOCKER_OPTS=\"\$DOCKER_OPTS $DAEMON_ARGS\"' | sudo tee -a /etc/default/docker; \
#                               sudo service docker restart;" || :                          
# elif [ "$lsb_dist" == "Boot2Docker" ]
# then
#     docker-machine ssh $NAME "sudo /etc/init.d/docker stop; \
#                               curl -s $URL > ~/docker; \
#                               sudo cp ~/docker /usr/local/bin/docker; \
#                               sudo chmod +x /usr/local/bin/docker; \
#                               echo 'EXTRA_ARGS=\"\$EXTRA_ARGS $DAEMON_ARGS\"' | sudo tee -a /var/lib/boot2docker/profile; \
#                               sudo /etc/init.d/docker start" || :       
# else
#     docker-machine scp $_base/docker.service $NAME:/home/docker
#     docker-machine ssh $NAME "sudo service docker stop; \
#                               rm -f ~/docker-latest; \
#                               wget  $URL; \
#                               sudo cp ~/docker-latest /usr/bin/docker; \
#                               sudo chmod +x /usr/bin/docker; \
#                               sudo cp ~/docker.service /etc/systemd/system/; \
#                               sudo mkdir -p /etc/systemd/system/docker.service.d; \
#                               echo '[Service]
# Environment=\"NETWORK_OPTS=$DAEMON_ARGS\"' | sudo tee -a /etc/systemd/system/docker.service.d/libnet.conf; \
#                               sudo systemctl daemon-reload; \
#                               sudo service docker start;" || :                          
# fi

if [ "$lsb_dist" == "Ubuntu" ]
then
    docker-machine ssh $NAME "sudo usermod -aG docker \$USER;" || : 
elif [ "$lsb_dist" == "Boot2Docker" ]
then
    docker-machine ssh $NAME "sudo /etc/init.d/docker stop; \
                              curl -sSL $URL > ~/docker;
                              sudo cp ~/docker /usr/local/bin/docker;
                              sudo chmod +x /usr/local/bin/docker;
                              echo 'EXTRA_ARGS=\"\$EXTRA_ARGS $DAEMON_ARGS\"' | sudo tee -a /var/lib/boot2docker/profile; \
                              sudo /etc/init.d/docker start" || :       
else
    docker-machine scp $_base/docker.service $NAME:/home/docker
    docker-machine ssh $NAME "sudo service docker stop; \
                              sudo cp ~/docker.service /etc/systemd/system/; \
                              sudo mkdir -p /etc/systemd/system/docker.service.d; \
                              echo '[Service]
Environment=\"NETWORK_OPTS=$DAEMON_ARGS\"' | sudo tee -a /etc/systemd/system/docker.service.d/libnet.conf; \
                              sudo systemctl daemon-reload; \
                              sudo service docker start;" || :                          
fi
