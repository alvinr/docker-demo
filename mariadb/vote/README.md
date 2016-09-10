# Orchestration & Networking demo

## Cavets
* has been tested on Docker 1.12.1
* has been tested on os-x 10.10 & 10.11
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 

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

## Running demo - Part One: Scale the app

To start app in development:

    $ cd vote/dev/
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker run alvinr/vote-schema:dev -h172.17.0.3  -uroot -pfoo

The app will be available at http://dev.myapp.com:5000. You can inspect the database

    $ docker run -it --rm --net dev_default mariadb sh -c "exec mysql -uroot -pfoo -hdev_mariadb_1"

    MariaDB [test]> select * from test.votes;
    MariaDB [test]> select * from test.vote_history;
    MariaDB [test]> select * from test.summary;

## Running demo - Part Two: Deploy into production

To start app in production:

    $ cd prod/
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker-compose -f setup.yml up

    $ docker $(docker-machine config swarm-0) network connect prod swarm-0/prod_haproxy_1

The app will be available at http://prod.myapp.com

## Running demo - Part Three: Scale web tier in production

    $ docker-compose scale web=5

You can log onto the MariaDB and look at data

    $ docker run -it --rm --net prod_back mariadb sh -c "exec mysql -uroot -pfoo -hprod_mariadb_1"

    MariaDB [test]> select * from test.votes;
    MariaDB [test]> select * from test.vote_history;
    MariaDB [test]> select * from test.summary;

# Building the images
If you want to rebuild the images for any reason, you will need to build, push and update the compose files as necessary (since you will push to a new repo)

## Building Images
Under the 'dev' and 'prod' directories, README.md file describe how to build all the images used by the demo.
