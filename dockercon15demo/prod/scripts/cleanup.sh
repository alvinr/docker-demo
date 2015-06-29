#!/bin/bash

eval "$(docker-machine env --swarm swarm-0)"

docker-compose stop
docker-compose rm -f
