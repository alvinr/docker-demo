# MariaDB + Galera - High Availability Demo
Showcase for HA facilities provided by Galera

## Running demo - Part Two: Deploy into production

To start app in production:

    $ cd prod
    $ source ../scripts/setup.sh
    $ docker network create -d overlay --attachable --opt encrypted myapp_back
    $ docker stack deploy -c docker-compose.stack.yml myapp

## Running demo - Part Three: Scale MariaDB Cluster

    $ docker service scale myapp_mariadb_cluster=3

The app will be available at http://prod.myapp.com

## Running demo - Part Four: Scale web tier in production

    $ docker service scale myapp_web=3

You can log onto the MariaDB and look at data

    $ docker run -it --rm --net myapp_back redis sh -c "redis-cli -h myapp_redis"

    myapp_redis:6379> hgetall votes
    1) "3d8552d2c97eef08"
    2) "b"

    myapp_redis:6379> lrange vote_history:3d8552d2c97eef08 0 -1
    1) "{\"vote\": \"a\", \"ts\": 1513632158.589084}"
    2) "{\"vote\": \"b\", \"ts\": 1513632162.072794}"
    3) "{\"vote\": \"c\", \"ts\": 1513632162.940543}"
    4) "{\"vote\": \"b\", \"ts\": 1513632163.676478}"
    5) "{\"vote\": \"a\", \"ts\": 1513632164.167802}"

    myapp_redis:6379> get total_votes
    "43"

    myapp_redis:6379> hgetall vote_summary
    1) "10.0.0.5"
    2) "32"
    3) "10.0.0.8"
    4) "6"
    5) "10.0.0.9"
    6) "5"

    MariaDB [(none)]> show status like "wsrep_cluster_size";
    +--------------------+-------+
    | Variable_name      | Value |
    +--------------------+-------+
    | wsrep_cluster_size | 3     |
    +--------------------+-------+
    1 row in set (0.00 sec)

## Running demo - Part Four: MaxScale routing tier in production

    $ docker service scale myapp_maxscale=2
    

