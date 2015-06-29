#!/bin/bash

eval "$(docker-machine env --swarm swarm-0)"
export PS1="~/prod-mongodb$ "

