# MaxScale Swarm demo image which includes DNS service discovery to configure MaxScale
Forked from: https://github.com/toughIQ/docker-maxscale

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/maxscale-swarm .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/maxscale-swarm
