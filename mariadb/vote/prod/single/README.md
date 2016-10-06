# Setup for Single MariaDB
This directory contains all the files required to run the vote application against a single MariaDB server config.

## Images

Various images are used by the 'prod' demo, see README.md in each of the following directories for build instructions
    - ../dev/schema

## Running demo - Part Two: Deploy into production

To start app in production:

    $ cd prod/single
    $ source ../scripts/setup.sh
    $ docker-compose up -d
    $ docker-compose -f schema.yml up

    $ docker network connect swarm-0/bridge single_haproxy_1

The app will be available at http://prod.myapp.com

## Running demo - Part Three: Scale web tier in production

    $ docker-compose scale web=4

You can log onto the MariaDB and look at data

    $ docker run -it --rm --net single_back mariadb sh -c "exec mysql -uroot -pfoo -hmariadb"

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



