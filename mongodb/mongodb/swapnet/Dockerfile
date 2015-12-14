FROM ubuntu:latest

# make sure we have curl
RUN apt-get update
RUN apt-get install -y curl

# add machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.4.0-rc1/docker-machine_linux-amd64 > docker-machine
RUN mv docker-machine /usr/bin/docker-machine
RUN chmod +x /usr/bin/docker-machine
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
VOLUME /etc/docker

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]