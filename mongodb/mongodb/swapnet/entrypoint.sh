#!/bin/sh
exec sudo docker service detach $2 $2.multihost
exec sudo docker service detach $3 $3.multihost
exec sudo docker service attach $3 $2.multihost
exec sudo docker service attach $2 $3.multihost