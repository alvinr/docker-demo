URL=$1
NAME=$2

if [ "$URL" == "" ]
then
  URL="http://experimental.docker.com/builds/Linux/x86_64/docker-latest"
fi

if [ "$NAME" == "" ]
then
  NAME="swarm"
fi

for NODE in `docker-machine ls -q | grep -E "$NAME-[0-9]+"`
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
      docker-machine ssh $NODE "curl -sL $URL > ~/docker"
      docker-machine ssh $NODE "sudo cp ~/docker /usr/bin/docker; sudo chmod +x /usr/bin/docker;sudo mv /var/log/upstart/docker.log /var/log/upstart/docker.log`date +%Y-%m-%d-%R`; sudo service docker start"
    else
      docker-machine ssh $NODE "sudo /etc/init.d/docker stop"
      docker-machine ssh $NODE "curl -sL $URL > ~/docker"
      docker-machine ssh $NODE "sudo cp ~/docker /usr/bin/docker; sudo chmod +x /usr/bin/docker;sudo /etc/init.d/docker start"
    fi 
done