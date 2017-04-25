FROM colinmollenhour/mariadb-galera-swarm

RUN apt-get update && apt-get install -y dnsutils netcat pv

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]