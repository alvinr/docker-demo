# Votes demo schema
Docker image to create the schema for development environment

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/vote-schema:dev .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/vote-schema:dev

## Run the docker image

    $ docker run alvinr/vote-schema:dev -h<hostname> -P<port number> -uroot -p<root password>       

    e.g. 

    $ docker run alvinr/vote-schema:dev -h172.17.0.2 -P3306 -uroot -pfoo