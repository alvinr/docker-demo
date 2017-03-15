FROM asosso/maxscale:2.0.4
MAINTAINER toughiq@gmail.com

# bring system up2date
RUN yum update -y && yum install -y bind-utils

# Dockerized MaxScale for Galera Cluster Backend
# FROM https://github.com/toughIQ/docker-maxscale

# We set some defaults for config creation. Can be overwritten at runtime.
ENV MAX_THREADS=4 \
    ENABLE_ROOT_USER=0 \ 
    SPLITTER_PORT=3306 \
    ROUTER_PORT=3307 \
    CLI_PORT=6603 \
    CONNECTION_TIMEOUT=600 \
    BACKEND_SERVER_LIST="" \
    BACKEND_SERVER_PORT="3306"

# We copy our config creator script to the container
COPY docker-entrypoint.sh /

# We expose our set Listener Ports
EXPOSE $SPLITTER_PORT $ROUTER_PORT $CLI_PORT

# We define the config creator as entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# We startup MaxScale as default command
CMD ["/usr/bin/maxscale","--nodaemon","--log=stdout"]