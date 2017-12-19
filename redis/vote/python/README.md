# Python image with MySQL Python dirver pre-installed

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/mariadb-python .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/mariadb-python
