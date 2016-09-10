FROM mariadb:10.1

COPY schema.sql /code/schema/schema.sql
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]