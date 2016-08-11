# Orchestration & Networking demo

## Cavets
* has been tested on os-x 10.10 and 10.11
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 

## Preparation

Create dev environment:

    $ cd common
    $ scripts/create-dev.sh
    $ echo "$(docker-machine ip dev) dev.myapp.com" | sudo tee -a /etc/hosts

Create a Swarm:

    $ eval $(docker-machine env dev)
    $ scripts/create-swarm.sh
    $ echo "$(docker-machine ip swarm-0) prod.myapp.com" | sudo tee -a /etc/hosts

Start the Viz:

     $ cd common/viz
     $ source scripts/setup.sh
     $ scripts/up.sh swarm-0
     $ echo "$(docker-machine ip swarm-consul) viz.myapp.com" | sudo tee -a /etc/hosts

The app will be available at http://viz.amyapp.com:3000    

## Running demo - Part One: Scale the app

To start app in development:

    $ cd dev/
    $ source scripts/setup.sh
    $ docker-compose build
    $ docker-compose up

The app will be available at http://dev.myapp.com:5000

To start app in production:

    $ cd prod/
    $ source scripts/setup.sh
    $ docker $(docker-machine config --swarm swarm-0) network create --driver overlay --internal prod
    $ docker-compose up -d
    $ docker $(docker-machine config swarm-0) network connect prod prod_haproxy_1
    $ docker $(docker-machine config swarm-0) network connect prod prod_discovery_1
    $ docker-compose scale web=5

The app will be available at http://prod.myapp.com

You can log onto the Aerospike and look at data with aql

    $ docker run -it --rm --net prod aerospike/aerospike-tools aql -h prod_aerospike_1

    aql> select * from test.votes
    aql> select * from test.summary

## Running demo - Part Two: Scale the DB

    $ docker-compose scale aerospike=3

You can look at the cluster topology with

    $ docker run -it --rm --net prod aerospike/aerospike-tools asadm -e i -h prod_aerospike_1



# Building the images
If you want to rebuild the images for any reason, you will need to build, push and update the compose files as necessary (since you will push to a new repo)

## Build the web app

    $ HUB_USER="my hub user"
    $ cd dev
    $ eval "$(docker-machine env dev)"
    $ docker build -t $HUB_USER/demo-webapp-as .
    $ docker push $HUB_USER/demo-webapp-as

## Build the aerospike images

    $ HUB_USER="my hub user"

    $ cd aerospike
    $ eval "$(docker-machine env dev)"
    $ docker build -t $HUB_USER/aerospike-server .
    $ docker push $HUB_USER/aerospike-server
