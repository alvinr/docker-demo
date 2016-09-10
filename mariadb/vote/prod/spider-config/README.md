# Docker image to setup MariaDB Spider Storage Engine

## Building the image

Build the image with the following steps

    $ export DOCKER_UN=alvinr
    $ docker build -t alvinr/mariadb-spider .

## Run the image to configure Spider Storage Engine
This assumes that you have already started a MariaDB server, in container named "mariadb"

Get the IP address of the MariaDB server
    $ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb

Configure Spider Storage Engine

    $ docker run alvinr/mariadb-spider -h<hostname> -P<port number> -uroot -p<root password>       

    e.g. 

    $ docker run alvinr/mariadb-spider -h172.17.0.2 -P3306 -uroot -pfoo    

## Confirm Spider Storage Engine is setup

    $ docker exec mariadb mysql -h<hostname> -P<port number> -uroot -p<root password> -e "SELECT engine, support, transactions, xa FROM information_schema.engines;"

    e.g.

    $ docker exec mariadb mysql -h172.17.0.2 -P3306 -uroot -pfoo -e "SELECT engine, support, transactions, xa FROM information_schema.engines WHERE engine='SPIDER';"