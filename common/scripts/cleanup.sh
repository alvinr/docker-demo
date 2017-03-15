#!/bin/bash
function do_dir() {
  local __dir=$1

  pushd .
  cd $1
  . scripts/cleanup.sh
  popd
}

do_dir "mongodb"
do_dir "aerospike"
do_dir "redis"
do_dir "mariadb"

export PS1="\h:\W$ "
