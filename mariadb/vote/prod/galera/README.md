# MariaDB + Galera - High Availability Demo
Showcase for HA facilities provided by Galera

## Running demo - Part Two: Deploy into production

To start app in production:

    $ cd prod/galera
    $ source ../scripts/setup.sh
    $ docker network create -d overlay --attachable --opt encrypted myapp_back
    $ docker stack deploy myapp -c docker-compose.stack.yml
    $ docker-compose -f schema.yml up


## Running demo - Part Three: Scale MariaDB Cluster

    $ docker service scale myapp_mariadb_cluster=3

The app will be available at http://prod.myapp.com

## Running demo - Part Four: Scale web tier in production

    $ docker service scale myapp_web=3

You can log onto the MariaDB and look at data

    $  docker run -it --rm --net myapp_back mariadb sh -c "mysql -uapp -pappfoo -hmariadb_cluster"

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

    MariaDB [(none)]> show status like "wsrep_cluster_size";
    +--------------------+-------+
    | Variable_name      | Value |
    +--------------------+-------+
    | wsrep_cluster_size | 3     |
    +--------------------+-------+
    1 row in set (0.00 sec)

## Running demo - Part Four: MaxScale routing tier in production

    $ docker service scale myapp_maxscale=2
    
You can use maxadmin to view request routing

    $ docker exec -it $(docker ps -f "label=com.mariadb.cluster=myapp-maxscale" --format "{{.ID}}") maxadmin show services

    Service 0x22b8300
    Service:                             Galera Service
    Router:                              readconnroute (0x7fa42c273140)
    State:                               Started
    Number of router sessions:      0
    Current no. of router sessions: 0
    Number of queries forwarded:    0
    Started:                             Tue Mar 21 15:58:08 2017
    Root user access:                    Disabled
    Backend databases:
        10.0.0.16:3306  Protocol: MySQLBackend
        10.0.0.15:3306  Protocol: MySQLBackend
        10.0.0.19:3306  Protocol: MySQLBackend
    Users data:                          0x22cc560
    Total connections:                   1
    Currently connected:                 1
    ...

