# Orchestration & Networking demo

## Cavets
* has been tested on os-x 10.10 only
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 

## Preparation

Create a Swarm:

    $ ./create-swarm.sh
    $ echo "$(docker-machine ip blog-0) prod.awesome-counter.com" | sudo tee -a /etc/hosts

The app will be available at http://viz.awesome-counter.com:3000    

## Running demo - Part One: Scale the app

To start app in production:

    $ eval $(docker-machine env --swarm blog-0)
    $ docker $(docker-machine config --swarm blog-0) network create --driver overlay --internal prod
    $ docker-compose up -d
    $ docker $(docker-machine config blog-0) network connect prod blog_discovery_1

## Running demo - Part Two: Scale the DB

    $ docker-compose scale aerospike=2

 You can log onto the Aerospike using by
    $ docker run -it --rm --net prod aerospike/aerospike-tools aql -h blog_aerospike_1

## Cleaning up the demo
    $ ./cleanup.sh

