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

if [ -z $MYSQL_PASSWORD ] && [ -f $MYSQL_PASSWORD_FILE ]; then
    MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi
exec mysql -p$MYSQL_PASSWORD $@ < /code/schema/schema.sql