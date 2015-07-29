#!/bin/bash
DOCKER=$1

for NODE in `docker-machine ls -q | grep -E 'swarm-[0-9]+'`
do
    echo Pushing to $NODE
    lsb_dist=""
    if [ ! -x $(docker-machine ssh $NODE "which lsb_release") ]
    then
      lsb_dist=$(docker-machine ssh $NODE "lsb_release -si" | cut -d" " -f 1)
    fi

    if [ "$lsb_dist" == "Ubuntu" ]
    then
      docker-machine ssh $NODE "sudo service docker stop"
      docker-machine scp $1 $NODE:/home/ubuntu/docker
      docker-machine ssh $NODE "sudo cp /home/ubuntu/docker /usr/bin/docker; sudo chmod +x /usr/bin/docker;sudo service docker start"
    else
      docker-machine ssh $NODE "sudo /etc/init.d/docker stop"
      docker-machine scp $1 $NODE:/home/docker/docker
      docker-machine ssh $NODE "sudo cp /home/docker/docker /usr/bin/docker; sudo chmod +x /usr/bin/docker;sudo /etc/init.d/docker start"
    fi 
done