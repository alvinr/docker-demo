#!/bin/bash

eval "$(docker-machine env --swarm mongodb-swarm)"

for YAML in "switch.yaml" "mdb_dev.yaml" "mdb_dev_cluster.yaml" "mdb_prod_cluster.yaml" ; do
  docker-compose -f ${YAML} stop
  docker-compose -f ${YAML} rm -f
done

docker rm -f app
docker-machine ssh mongodb-server1 "sudo rm -rf /data/db/*"
docker-machine ssh mongodb-server2 "sudo rm -rf /data/db/*"
docker-machine ssh mongodb-server3 "sudo rm -rf /data/db/*"

