FROM mariadb:10.1.16

RUN apt-get update && apt-get install -y galera-arbitrator-3 && \
    rm -rf /var/lib/apt/lists/*

COPY galera-entrypoint.sh /

RUN chown mysql:mysql /etc/mysql/my.cnf

EXPOSE 3306 4444 4567 4567/udp 4568

ENTRYPOINT ["/galera-entrypoint.sh"]
CMD ["mysqld"]