# Orchestration & Networking demo

## Cavets
* has been tested on os-x 10.10 only
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

The app will be available at http://viz.myapp.com:3000    

## Running demo - Part One: Scale the app

To start app in development:

    $ cd count/dev/
    $ source scripts/setup.sh
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

The app will be available at http://prod.awesome-counter.com

## Running demo - Part Two: Scale the DB

    $ docker-compose scale aerospike=3

 You can log onto the Aerospike using by
    $ docker run -it --rm --net prod aerospike/aerospike-tools aql -h prod_aerospike_1


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

# Amazon EC2 - WORK IN PROGRESS!
Some work has been done to make this demo work on EC2. You will need to setup a VPC and configure it correctly (blog post is in the works). Creating through the "VPC Wizard" is the simplest way to get this right. The swarm can be created on EC2 thus

    $ export AWS_ACCESS_KEY_ID=<my key>
    $ export AWS_SECRET_ACCESS_KEY=<my secret key>
    $ export AWS_SECURITY_GROUP=<my group name eg. alvin-dockercon>
    $ export AWS_SUBNET_ID=<my subnet eg. subnet-6c87e947>
    $ export AWS_VPC_ID=<my VPC name eg. alvin-dockercon>

If you are not using the default Region of `us-east-1` then you will also need to set your Region and Zone that the VPC and Subnet were created in.

    $ export AWS_DEFAULT_REGION=us-west-2
    $ export AWS_ZONE=c

    $ scripts/create-swarm.sh amazonec2

In order for this to work, you will need to create a VPC via the VPC Wizard (not by just creating the VPC). You will also need to ensure that the secutiry group opens up the following ports

Docker Engine / Swarm
- TCP / 2376 / 0.0.0.0
- TCP / 3376 / 0.0.0.0

Consul
- TCP / 8400 / 0.0.0.0
- TCP / 8500 / 0.0.0.0
- UDP / 8600 / 0.0.0.0

Serf
- TCP / 7946 / 0.0.0.0

Web App
- TCP / 80 / 0.0.0.0

VxLAN
- UDP / 46354 / 0.0.0.0
Once the following is resolved https://github.com/docker/libnetwork/issues/358#issuecomment-128160349 
- UDP / 4789 / 0.0.0.0

You will also need to modify `prod/haproxy.yml` to change the volumnes mounted to the container
     # boot2docker images use the following
     # - "/var/lib/boot2docker:/etc/docker"
     # ubuntu / ec2 images use
     - "/etc/docker:/etc/docker"
