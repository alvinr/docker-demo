#!/bin/bash
NAME=$1
DAEMON_ARGS=$2
URL=$3

if [ "$URL" == "" ]
then
  URL="http://experimental.docker.com/builds/Linux/x86_64/docker-latest"
fi

# dockercon15 demo
# URL="https://bfirsh.s3.amazonaws.com/docker-multihost/docker-1.8.0-dev-91fd45c"

lsb_dist=""
if [ ! -x $(docker-machine ssh $NAME "which lsb_release") ]
then
  lsb_dist=$(docker-machine ssh $NAME "lsb_release -si" | cut -d" " -f 1)
fi

if [ "$lsb_dist" == "Ubuntu" ]
then
    docker-machine ssh $NAME "sudo service docker stop; \
                              sudo usermod -aG docker \$USER; \
                              curl -s $URL > /home/ubuntu/docker; \
                              sudo cp /home/ubuntu/docker /usr/bin/docker; \
                              sudo chmod +x /usr/bin/docker; \
                              echo 'DOCKER_OPTS=\"\$DOCKER_OPTS $DAEMON_ARGS\"' | sudo tee -a /etc/default/docker; \
                              sudo reboot" || :                          
else
    docker-machine ssh $NAME "sudo killall docker; \
                              sudo rm -f /home/docker/docker-latest; \
                              wget  $URL; \
                              sudo cp /home/docker/docker-latest /usr/bin/docker; \
                              sudo chmod +x /usr/bin/docker; \
                              echo 'DOCKER_OPTS=\"\$DOCKER_OPTS $DAEMON_ARGS\"' | sudo tee -a /etc/default/docker; \
                              sudo reboot" || :                          
fi