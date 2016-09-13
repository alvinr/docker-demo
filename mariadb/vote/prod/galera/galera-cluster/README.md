# Galera Cluster Image
This is a private image for Galera cluster. I had trouble with the public ones, it may have just been a usage issue - but to debug that I created my own image. At some future point it may be worth going back to one of the other images - buy hey, who that that time!

This image is used by the Docker Compose file in the directory above.

## Build the Docker image

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/alvinr/mariadb-galera .
    $ docker push $DOCKER_UN/alvinr/mariadb-galera