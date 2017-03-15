#!/bin/bash

# Exit on errors but report line number
set -e
err_report() {
    echo "start.sh: Trapped error on line $1"
    exit
}
trap 'err_report $LINENO' ERR

# Set 'TRACE=y' environment variable to see detailed output for debugging
if [ "$TRACE" = "y" ]; then
    set -x
fi

# Set data directory permissions for later use of "gosu"
chown mysql /var/lib/mysql
touch /var/lib/mysql/pre-boot.flag

#
# Resolve node address
#
if [ -z "$NODE_ADDRESS" ]; then
    # Support Weave/Kontena
    NODE_ADDRESS=$(ip addr | awk '/inet/ && /ethwe/{sub(/\/.*$/,"",$2); print $2}')
fi
if [ -z "$NODE_ADDRESS" ]; then
    # Support Docker Swarm Mode
    NODE_ADDRESS=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}' | head -n 1)
elif [[ "$NODE_ADDRESS" =~ [a-zA-Z][a-zA-Z0-9:]+ ]]; then
    # Support interface - e.g. Docker Swarm Mode uses eth0
    NODE_ADDRESS=$(ip addr | awk "/inet/ && / $NODE_ADDRESS\$/{sub(/\\/.*$/,\"\",\$2); print \$2}" | head -n 1)
elif ! [[ "$NODE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Support grep pattern. E.g. ^10.0.1.*
    NODE_ADDRESS=$(getent hosts $(hostname) | grep -e "$NODE_ADDRESS")
fi
if ! [[ "$NODE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Could not determine NODE_ADDRESS: $NODE_ADDRESS"
    exit 1
fi
echo "...------======------... MariaDB Galera Start Script ...------======------..."
echo "Got NODE_ADDRESS=$NODE_ADDRESS"

# Read optional secrets from files
if [ -z $XTRABACKUP_PASSWORD ] && [ -f $XTRABACKUP_PASSWORD_FILE ]; then
    XTRABACKUP_PASSWORD=$(cat $XTRABACKUP_PASSWORD_FILE)
fi
if [ -z $SYSTEM_PASSWORD ] && [ -f $SYSTEM_PASSWORD_FILE ]; then
    SYSTEM_PASSWORD=$(cat $SYSTEM_PASSWORD_FILE)
fi
if [ -z $MYSQL_ROOT_PASSWORD ] && [ -f $MYSQL_ROOT_PASSWORD_FILE ]; then
    MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
fi
if [ -z $MYSQL_PASSWORD ] && [ -f $MYSQL_PASSWORD_FILE ]; then
    MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

# System password defaults to hash of xtrabackup password
if test -n "$XTRABACKUP_PASSWORD"; then
    SYSTEM_PASSWORD=${SYSTEM_PASSWORD:-$(echo "$XTRABACKUP_PASSWORD" | sha256sum | awk '{print $1;}')}
fi

#
# Utility modes
#
case "$1" in
    sleep)
        echo "Sleeping forever..."
        sleep infinity
        exit
        ;;
    no-galera)
        echo "Starting with Galera disabled"
        shift 1
        gosu mysql mysqld --console \
            --wsrep-on=OFF \
            --default-time-zone="+00:00" \
            "$@" 2>&1
        exit
        ;;
    bash)
        shift 1
        /bin/bash "$@"
        exit
        ;;
    seed|node)
        ;;
    *)
        echo "sleep|no-galera|bash|seed|node <othernode>,..."
        exit 1
esac

# XTRABACKUP_PASSWORD required from this point forward
[ -z "$XTRABACKUP_PASSWORD" ] && { echo "XTRABACKUP_PASSWORD not set"; exit 1; }
[ -z "$SYSTEM_PASSWORD" ] && SYSTEM_PASSWORD=$(echo "$XTRABACKUP_PASSWORD" | sha256sum | awk '{print $1;}')
CLUSTER_NAME=${CLUSTER_NAME:-cluster}
GCOMM_MINIMUM=${GCOMM_MINIMUM:-2}
GCOMM=""
MYSQL_MODE_ARGS=""

# Allow for easily adding more startup scripts
if [ -f /usr/local/lib/startup.sh ]; then
    source /usr/local/lib/startup.sh
fi

# Generate init file to create required users
if   ( [ "$1" = "node" ] && [ -f /var/lib/mysql/force-cluster-bootstrapping ] ) \
  || ( [ "$1" = "seed" ] && ! [ -f /var/lib/mysql/skip-cluster-bootstrapping ] )
then
    echo "Generating cluster bootstrap script..."
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
        echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
    fi
    
    CLIENT_NODE_ADDR=${CLIENT_NODE_ADDR}
    if [ -z "$CLIENT_NODE_ADDR" ]; then
        CLIENT_NODE_ADDR = "%"
    fi

    cat >/tmp/bootstrap.sql <<EOF
CREATE USER IF NOT EXISTS 'xtrabackup'@'127.0.0.1' IDENTIFIED BY '$XTRABACKUP_PASSWORD';
GRANT RELOAD,LOCK TABLES,REPLICATION CLIENT ON *.* TO 'xtrabackup'@'127.0.0.1';
CREATE USER IF NOT EXISTS 'xtrabackup'@'localhost' IDENTIFIED BY '$XTRABACKUP_PASSWORD';
GRANT RELOAD,LOCK TABLES,REPLICATION CLIENT ON *.* TO 'xtrabackup'@'localhost';
CREATE USER IF NOT EXISTS 'system'@'127.0.0.1' IDENTIFIED BY '$SYSTEM_PASSWORD';
GRANT PROCESS,SHUTDOWN ON *.* TO 'system'@'127.0.0.1';
CREATE USER IF NOT EXISTS 'system'@'localhost' IDENTIFIED BY '$SYSTEM_PASSWORD';
GRANT PROCESS,SHUTDOWN ON *.* TO 'system'@'localhost';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1';
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('$MYSQL_ROOT_PASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS 'root'@'localhost';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
EOF

    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> /tmp/bootstrap.sql
    fi

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> /tmp/bootstrap.sql
        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> /tmp/bootstrap.sql
        fi
        if [ "MAXSCALE_PRIVS" ]; then
            echo "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' ;" >> /tmp/bootstrap.sql
        fi
    fi
    echo "FLUSH PRIVILEGES;" >> /tmp/bootstrap.sql

    MYSQL_MODE_ARGS+=" --init-file=/tmp/bootstrap.sql"
    rm -f /var/lib/mysql/force-cluster-bootstrapping
    touch /var/lib/mysql/skip-cluster-bootstrapping
fi

#
# Start modes:
#  - seed - Start a new cluster - run only once and use 'node' after cluster is started
#  - node - Join an existing cluster
#
case "$1" in
    seed)
        MYSQL_MODE_ARGS+=" --wsrep-on=ON --wsrep-new-cluster"
        shift 1
        echo "Starting seed node"
        ;;
    node)
        MYSQL_MODE_ARGS+=" --wsrep-on=ON"
        if [ -z "$2" ]; then
            echo "Missing master node address"
            exit 1
        fi
        ADDRS="$2"
        RESOLVE=0
        SLEEPS=0
        while true; do
            SEP=""
            GCOMM=""
            for ADDR in ${ADDRS//,/ }; do
                if [[ "$ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    GCOMM+="$SEP$ADDR"
                else
                    RESOLVE=1
                    GCOMM+="$SEP$(getent hosts "$ADDR" | awk '{ print $1 }' | paste -sd ",")"
                fi
                if [ -n "$GCOMM" ]; then
                    SEP=,
                fi
            done
            GCOMM=${GCOMM%%,}                        # strip trailing commas
            GCOMM=$(echo "$GCOMM" | sed 's/,\+/,/g') # strip duplicate commas

            # It is possible that containers on other nodes aren't running yet and should be waited on
            # before trying to start. For example, this occurs when updated container images are being pulled
            # by `docker service update <service>` or on a full cluster power loss
            COUNT=$(echo "$GCOMM" | tr ',' "\n" | sort -u | grep -v -e "^$NODE_ADDRESS\$" -e '^$' | wc -l)
            if [ $RESOLVE -eq 1 ] && [ $COUNT -lt $(($GCOMM_MINIMUM - 1)) ]; then
                echo "Waiting for at least $GCOMM_MINIMUM IP addresses to resolve..."
                SLEEPS=$((SLEEPS + 1))
                sleep 3
            else
                break
            fi

            # After 90 seconds reduce GCOMM_MINIMUM
            if [ $SLEEPS -ge 30 ]; then
                SLEEPS=0
                GCOMM_MINIMUM=$((GCOMM_MINIMUM - 1))
                echo "Reducing GCOMM_MINIMUM to $GCOMM_MINIMUM"
            fi
        done
        shift 2
        echo "Starting node, connecting to gcomm://$GCOMM"
        ;;
esac

# Pre-boot completed
rm -f /var/lib/mysql/pre-boot.flag

# start processes
set +e -m

# Allow external processes to write to docker logs (wsrep_notify_cmd)
fifo=/tmp/mysql-console
rm -f $fifo && mkfifo $fifo && chown mysql $fifo && tail -f $fifo &
tail_pid=$!

function shutdown () {
    echo "Received TERM|INT signal. Shutting down..."
    mysql -u system -h 127.0.0.1 -p$SYSTEM_PASSWORD -e 'SHUTDOWN'
    # Since this is docker, expect that if we don't shut down quickly enough we will get killed anyway
}
trap shutdown TERM INT

# Port 8080 only reports healthy when ready to serve clients
# Use this one for load balancer health checks
galera-healthcheck -user=system -password="$SYSTEM_PASSWORD" \
    -port=8080 \
    -availWhenDonor=false \
    -availWhenReadOnly=false \
    -pidfile=/var/run/galera-healthcheck-1.pid >/dev/null &

# Port 8081 reports healthy as long as the server is synced or donor/desynced state
# Use this one to help other nodes determine cluster state before launching server
galera-healthcheck -user=system -password="$SYSTEM_PASSWORD" \
    -port=8081 \
    -availWhenDonor=true \
    -availWhenReadOnly=true \
    -pidfile=/var/run/galera-healthcheck-2.pid >/dev/null &

gosu mysql mysqld.sh --console \
    $MYSQL_MODE_ARGS \
    --wsrep_cluster_name=$CLUSTER_NAME \
    --wsrep_cluster_address=gcomm://$GCOMM \
    --wsrep_node_address=$NODE_ADDRESS:4567 \
    --wsrep_sst_auth=xtrabackup:$XTRABACKUP_PASSWORD \
    --default-time-zone=+00:00 \
    "$@" 2>&1 &
wait $! || true
RC=$?

echo "MariaDB exited with return code ($RC)"
test -f /var/lib/mysql/grastate.dat && cat /var/lib/mysql/grastate.dat

test -s /var/run/galera-healthcheck-1.pid && kill $(cat /var/run/galera-healthcheck-1.pid)
test -s /var/run/galera-healthcheck-2.pid && kill $(cat /var/run/galera-healthcheck-2.pid)

echo "Goodbye"
exit $RC
