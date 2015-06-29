#!/bin/bash
docker-machine rm $(docker-machine ls -q | grep swarm)
