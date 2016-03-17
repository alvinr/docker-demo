#!/bin/bash
NAME=$1
if [ "$NAME" == "" ]
then
  NAME="dev"
fi

eval "$(docker-machine env $NAME)"
export PS1="~/dev-app$ "
