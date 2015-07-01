#!/bin/bash
docker-machine rm -f $(docker-machine ls -q | grep swarm)
