## Images for 'dev'

Various images are used by the 'prod' demo, see README.md in each of the following directories for build instructions
    - schema

To build the demo application

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/demo-webapp-vote:mariadb .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/demo-webapp-vote:mariadb