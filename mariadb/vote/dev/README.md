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
    $ docker-compose build
    $ docker-compose up -d
    $ docker-compose -f schema.yml up

The app will be available at http://dev.myapp.com:5000. You can inspect the database

    $ docker run -it --rm --net dev_default mariadb sh -c "exec mysql -uroot -pfoo -hdev_mariadb_1"

   MariaDB [(none)]> select * from test.votes;
    +------------+------+
    | voter_id   | vote |
    +------------+------+
    | 2147483647 | a    |
    +------------+------+
    1 row in set (0.00 sec)

    MariaDB [(none)]> select * from test.vote_history;
    +------------+---------------+------+
    | voter_id   | ts            | vote |
    +------------+---------------+------+
    | 2147483647 | 1473802139707 | a    |
    | 2147483647 | 1473802142295 | b    |
    | 2147483647 | 1473802142812 | c    |
    | 2147483647 | 1473802143322 | b    |
    | 2147483647 | 1473802143881 | a    |
    | 2147483647 | 1473802144355 | b    |
    | 2147483647 | 1473802144760 | c    |
    | 2147483647 | 1473802145950 | b    |
    | 2147483647 | 1473802146378 | a    |
    +------------+---------------+------+
    9 rows in set (0.00 sec)

    MariaDB [(none)]> select * from test.summary;
    +-------------+-------+
    | category    | total |
    +-------------+-------+
    | 10.0.0.2    |    18 |
    | 10.0.0.7    |     1 |
    | 10.0.0.8    |     1 |
    | 10.0.0.9    |     1 |
    | total_votes |    21 |
    +-------------+-------+
    5 rows in set (0.00 sec)
