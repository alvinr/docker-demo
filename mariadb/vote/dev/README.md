# 'dev' directory

# Images
Various images are used by the 'dev' demo, see README.md in each of the following directories for build instructions
    - schema

To build the demo application

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/demo-webapp-vote:mariadb .

If you want to share the image, push to docker hub
    $ docker push $DOCKER_UN/demo-webapp-vote:mariadb


## Running demo - Part One: Develop the app

To start app in development:

    $ cd vote/dev/
    $ source scripts/setup.sh
    $ docker-compose up -d
    $ docker-compose -f setup.yml up

The app will be available at http://dev.myapp.com:5000. You can inspect the database

    $ docker run -it --rm --net dev_default mariadb sh -c "exec mysql -uroot -pfoo -hdev_mariadb_1"

    MariaDB [(none)]> select * from test.votes;
    MariaDB [(none)]> select * from test.vote_history;
    MariaDB [(none)]> select * from test.summary;
