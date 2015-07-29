# Orchestration & Networking demo

## Cavets
* has been tested on os-x 10.10 only
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 
* you will need an "experimental" version of "docker" client executable for Darwin
    curl https://experimental.docker.com/builds/Darwin/x86_64/docker-latest > /usr/local/bin/docker

## Preparation

Create dev environment:

    $ scripts/create-dev.sh
    $ echo "$(docker-machine ip dev) dev.dockercon.com" | sudo tee -a /etc/hosts

Create a Swarm:

    $ eval $(docker-machine env dev)
    $ scripts/create-swarm.sh
    $ echo "$(docker-machine ip swarm-0) prod.dockercon.com" | sudo tee -a /etc/hosts

Start the Viz:

     $ cd viz
     $ source scripts/setup.sh
     $ scripts/up.sh swarm-0
     $ echo "$(docker-machine ip dev) viz.dockercon.com" | sudo tee -a /etc/hosts

The app will be available at http://viz.dockercon.com:3000    

## Running demo - Part One: Scale the app

To start app in development:

    $ cd dev/
    $ source scripts/setup.sh
    $ docker-compose up

The app will be available at http://dev.dockercon.com:5000

To start app in production:

    $ cd prod/
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker-compose scale web=5

The app will be available at http://prod.dockercon.com

## Running demo - Part Two: Scale the DB

Start the MongoDB Cluster
    $ cd mongodb
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker run alvinr/init-mongodb --nodb
    $ docker-machine ssh swarm-0 "docker service detach mongodb_mongodb_1 mongodb_mongodb_1.multihost"
    $ docker-machine ssh swarm-0 "docker service detach prod_mongodb_1 prod_mongodb_1.multihost"
    $ docker-machine ssh swarm-0 "docker service attach mongodb_mongodb_1 prod_mongodb_1.multihost"

 You can log onto the MongoDb using by
    $ docker run -it --rm alvinr/mongo mongodb_mongodb_1:27017   

## Running demo - Part Three: Move the DB
<TBD> need to look at runc checkpoint & restore, examples here https://github.com/crosbymichael/uhaul/blob/master/node.go

## Cleaning up the demo
    $ scripts/cleanup.sh

# Building the images
If you want to rebuild the images for any reason, you will need to build, push and update the compose files as necessary (since you will push to a new repo)

## Build the web app

    $ cd dev
    $ eval "$(docker-machine env dev)"
    $ docker build -t myuser/demo-webapp .
    $ docker push mysuer/demo-webapp

## Build the mongo images

    $ HUB_USER="my hub user"

    $ cd mongodb/mongo
    $ eval "$(docker-machine env dev)"
    $ docker build -t $HUB_USER/mongo .
    $ docker push $HUB_USER/mongo

    $ cd mongodb/mongos
    $ eval "$(docker-machine env dev)"
    $ docker build -t $HUB_USER/mongos .
    $ docker push $HUB_USER/mongos

    $ cd mongodb/init-mongo
    $ eval "$(docker-machine env dev)"
    $ docker build -t $HUB_USER/init-mongo .
    $ docker push $HUB_USER/init-mongo
