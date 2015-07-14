#!/bin/bash
NAME=$1
DAEMON_ARGS=$2

# docker-machine ssh $NAME "sudo killall docker; \
#                           curl -s https://bfirsh.s3.amazonaws.com/docker-multihost/docker-1.8.0-dev-91fd45c > /home/docker/docker; \
#                           sudo cp /home/docker/docker /usr/local/bin/docker; \
#                           sudo chmod +x /usr/local/bin/docker; \
#                           sudo chmod a+w /var/lib/boot2docker/profile; \
#                           echo 'EXTRA_ARGS=\"\$EXTRA_ARGS $DAEMON_ARGS\"' | tee -a /var/lib/boot2docker/profile; \
#                           sudo /etc/init.d/docker restart" || true

docker-machine ssh $NAME "sudo killall docker; \
                          curl -s https://experimental.docker.com/builds/Linux/x86_64/docker-latest > /home/docker/docker; \
                          sudo cp /home/docker/docker /usr/local/bin/docker; \
                          sudo chmod +x /usr/local/bin/docker; \
                          sudo chmod a+w /var/lib/boot2docker/profile; \
                          echo 'EXTRA_ARGS=\"\$EXTRA_ARGS $DAEMON_ARGS\"' | tee -a /var/lib/boot2docker/profile; \
                          sudo /etc/init.d/docker restart" || :                          