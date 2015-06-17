#!/bin/bash

eval "$(docker-machine env --swarm mongodb-swarm)"

docker-compose -f mdb.yaml stop
docker-compose -f switch.yaml stop
docker-compose -f app.yaml stop
docker-compose -f mdb.yaml rm -f
docker-compose -f switch.yaml rm -f
docker-compose -f app.yaml rm -f
docker-machine ssh mongodb-server1 "sudo rm -rf /data/db/*"
docker-machine ssh mongodb-server2 "sudo rm -rf /data/db/*"
docker-machine ssh mongodb-server3 "sudo rm -rf /data/db/*"

