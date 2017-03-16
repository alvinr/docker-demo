# MariaDB + Galera - High Availability Demo
Showcase for HA facilities provided by Galera

## Running demo - Part Two: Deploy into production

To start app in production:

    $ cd prod/galera
    $ source ../scripts/setup.sh
    $ docker network create -d overlay --attachable myapp_back
    $ docker stack deploy myapp -c docker-compose.stack.yml
    $ docker-compose -f schema.yml up

The app will be available at http://prod.myapp.com

## Running demo - Part Three: Scale web tier in production

    $ docker service scale myapp_web=4

You can log onto the MariaDB and look at data

    $  docker run -it --rm --net myapp_back mariadb sh -c "mysql -uroot -pfoo -hmariadb_cluster"

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

    $ docker stack scale myapp_maxscale=4
    
You can use maxadmin to view request routing

    $ docker $(docker-machine config swarm-2) exec -it 63bb00e678b4 maxadmin show services
