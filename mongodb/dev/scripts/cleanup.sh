#!/bin/bash

scripts/setup.sh $@

docker-compose stop
docker-compose rm -f
