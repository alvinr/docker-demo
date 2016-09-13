# Votes demo schema
Docker images to create the schema for production environment
    - Spider node
    - Partition (shard) nodes

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ cd spider
    $ docker build -t $DOCKER_UN/vote-schema:spider .
    $ docker push $DOCKER_UN/vote-schema:spider
    $ cd ../shard
    $ docker build -t $DOCKER_UN/vote-schema:shard .
    $ docker push $DOCKER_UN/vote-schema:shard


## Run the docker image on the spider node

    $ docker run alvinr/vote-schema:spider -h<hostname> -P<port number> -uroot -p<root password>       

    e.g. 

    $ docker run alvinr/vote-schema:spider -h172.17.0.2 -P3306 -uroot -pfoo

## Run the docker image on the shard node

    $ docker run alvinr/vote-schema:shard -h<hostname> -uroot -p<root password>       

    e.g. 

    $ docker run alvinr/vote-schema:shard -h172.17.0.2 -uroot -pfoo
