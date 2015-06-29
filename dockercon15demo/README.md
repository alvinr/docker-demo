# Orchestration & Networking demo

## Cavets
* has been etsted on os-x 10.10 only
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 
* you will need an "experimental" version of "docker" client executable for Darwin
    curl https://experimental.docker.com/builds/Darwin/x86_64/docker-latest > /usr/local/bin/docker

## Preparation

Create dev environment:

    $ scripts/create-dev.sh
    $ echo "$(docker-machine ip dev) dev.dockercon.com" | sudo tee -a /etc/hosts

Create a Swarm:

    $ scripts/create-swarm.sh
    $ echo "$(docker-machine ip swarm-0) demo.dockercon.com" | sudo tee -a /etc/hosts

Start the Viz:

     $ cd viz
     $ source scripts/setup.sh
     $ scripts/up.sh swarm-0
     $ echo "$(docker-machine ip dev) viz.dockercon.com" | sudo tee -a /etc/hosts

## Running demo - Part One: Scale the app

To start app in development:

    $ cd dev/
    $ source scripts/setup.sh
    $ docker-compose up

Run `docker-machine ip dev` and open this in a web browser on port 5000 to view dev environment.

To start app in production:

    $ cd prod/
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker-compose scale web=10

The app will be available at http://demo.dockercon.com

## Running demo - Part Two: Scale the DB

Start the MongoDB Cluster
    $ cd mongodb
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker run alvinr/init-mongo mongodb_mongodb_1:27017
    $ docker-machine ssh swarm-0
        $ docker service detach prod_mongodb_1 prod_mongodb_1.multihost
        $ docker service attach mongodb_mongodb_1 prod_mongodb_1.multihost

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

    $ cd mongodb/mongo
    $ eval "$(docker-machine env dev)"
    $ docker build -t myuser/mongo build .
    $ docker push myuser/mongo

    $ cd mongodb/mongos
    $ eval "$(docker-machine env dev)"
    $ docker build -t myuser/mongos build .
    $ docker push myuser/mongos

    $ cd mongodb/init-mongo
    $ eval "$(docker-machine env dev)"
    $ docker build -t myuser/init-mongo build .
    $ docker push myuser/init-mongo
