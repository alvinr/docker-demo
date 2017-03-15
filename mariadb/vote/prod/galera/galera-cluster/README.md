# Galera demo image. Includes setting correct prvlidges for MaxScale

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/mariadb-galera-swarm .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/mariadb-galera-swarm
