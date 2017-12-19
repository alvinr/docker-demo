# Orchestration & Networking demo

## Overview
This shows a development life-cycle:
- building an application in development
- testing the application locally
- using the development image, deploying into production
-- adding a load balancer (HAProxy) infront of the Web application
-- scaling the Web farm
-- deploying a Galera (for HA) or Spider (for Scaling) MariaDB cluster

## Preparation

Create dev environment VM:

    $ cd common
    $ scripts/create-dev.sh
    $ echo "$(docker-machine ip dev) dev.myapp.com" | sudo tee -a /etc/hosts

Create a Swarm VMs:

    $ eval $(docker-machine env dev)
    $ source scripts/create-swarm.sh
    $ docker network create -d overlay --attachable myapp_back    
    $ echo "$(docker-machine ip swarm-0) prod.myapp.com" | sudo tee -a /etc/hosts

Start the Viz:

     $ cd common/viz
     $ source scripts/setup.sh
     $ docker stack deploy viz -c docker-compose.stack.yml
     $ echo "$(docker-machine ip swarm-0) viz.myapp.com" | sudo tee -a /etc/hosts

The app will be available at http://viz.myapp.com:3000    

## Running the demo
Specifc instructions are included in each of the major sub-directories
- dev
- prod/galera (for the HA demo)
- prod/spider (for the scaling demo)

# Building Images
Under the 'dev' and 'prod' directories, README.md file describe how to build all the images used by the demo.
