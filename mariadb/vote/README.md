# Orchestration & Networking demo

## Cavets
* has been tested on Docker 1.12.1
* has been tested on OS-X 10.11
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else.

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
    $ scripts/create-swarm.sh
    $ echo "$(docker-machine ip swarm-0) prod.myapp.com" | sudo tee -a /etc/hosts

Start the Viz:

     $ cd common/viz
     $ source scripts/setup.sh
     $ scripts/up.sh swarm-0
     $ echo "$(docker-machine ip swarm-consul) viz.myapp.com" | sudo tee -a /etc/hosts

The app will be available at http://viz.myapp.com:3000    

## Running the demo
Specifc instructions are included in each of the major sub-directories
- dev
- prod/galera (for the HA demo)
- prod/spider (for the scaling demo)

# Building the images
If you want to rebuild the images for any reason, you will need to build, push and update the compose files as necessary (since you will push to a new repo)

## Building Images
Under the 'dev' and 'prod' directories, README.md file describe how to build all the images used by the demo.
