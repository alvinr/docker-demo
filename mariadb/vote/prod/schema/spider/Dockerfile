FROM mariadb:10.1

COPY schema-spider.sql /code/schema/schema-spider.sql
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]