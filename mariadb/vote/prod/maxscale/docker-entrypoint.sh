#!/bin/bash
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

# Read optional secrets from files
if [ -z $MAX_PASS ] && [ -f $MAX_PASS_FILE ]; then
    MAX_PASS=$(cat $MAX_PASS_FILE)
fi

# if service discovery was activated, we overwrite the BACKEND_SERVER_LIST with the
# results of DNS service lookup
if [ -n "$DB_SERVICE_NAMES" ]; then
    BACKEND_SERVER_LIST=""
    IFS=' ' read -r -a service_names <<< $DB_SERVICE_NAMES
    for i in ${!service_names[@]}; do
        server_ips=`dig tasks.${service_names[$i]} | awk "/tasks.${service_names[$i]}./ {print \\$5}"|awk 'NF'|tr '\n' ','|tr -d ' '|sed 's/,$//'`
        if [ -n "$server_ips" ]; then
            if [ -z "$BACKEND_SERVER_LIST" ]; then
                BACKEND_SERVER_LIST="$server_ips"
            else
                BACKEND_SERVER_LIST="$BACKEND_SERVER_LIST,$server_ips"
            fi
        fi
    done
fi

# We break our IP list into array
IFS=',' read -r -a backend_servers <<< $BACKEND_SERVER_LIST

if [ ${#backend_servers[@]} != "$DB_TARGET_COUNT" ]; then
    echo Only found ${#backend_servers[@]} / $DB_TARGET_COUNT backend servers
    exit 1
fi

config_file="/etc/maxscale.cnf"

# We start config file creation

cat <<EOF > $config_file
[maxscale]
threads=$MAX_THREADS

[Galera Service]
type=service
router=readconnroute
router_options=synced
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
passwd=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER

[Galera Listener]
type=listener
service=Galera Service
protocol=MySQLClient
port=$ROUTER_PORT

[Splitter Service]
type=service
router=readwritesplit
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
passwd=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER

[Splitter Listener]
type=listener
service=Splitter Service
protocol=MySQLClient
port=$SPLITTER_PORT

[Galera Monitor]
type=monitor
module=galeramon
servers=${BACKEND_SERVER_LIST// /,}
disable_master_failback=1
user=$MAX_USER
passwd=$MAX_PASS

[CLI]
type=service
router=cli
[CLI Listener]
type=listener
service=CLI
protocol=maxscaled
port=6603

[MaxAdmin]
type=service
router=cli

[MaxAdmin Unix Listener]
type=listener
service=MaxAdmin
protocol=maxscaled
socket=default

[MaxAdmin Inet Listener]
type=listener
service=MaxAdmin
protocol=maxscaled
address=localhost
port=6603

# Start the Server block
EOF

# add the [server] block
for i in ${!backend_servers[@]}; do
cat <<EOF >> $config_file
[${backend_servers[$i]}]
type=server
address=${backend_servers[$i]}
port=$BACKEND_SERVER_PORT
protocol=MySQLBackend

EOF

done

if [ "$TRACE" = "y" ]; then
    cat $config_file
fi

exec "$@"
