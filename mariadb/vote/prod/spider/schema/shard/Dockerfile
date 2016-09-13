FROM mariadb:10.1

COPY schema-shard.sql /code/schema/schema-shard.sql
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]