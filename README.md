# Orchestration & Networking demo
This repo contains some basic Docker demos and integration with various Databases
- Aerospike
- MariaDB
- MongoDB

At various times these have worked, but Docker is an ever changing beast, so no guarantee these will continue to work with the current Docker release.

The goal of the demo is to show the end to end development life-cycle building a Web + database application with the Docker eco-system. The demo specifically shows
- Deployment & Testing in development
- Definition & orchestration of services, in development and production
- Injecting production requirements e.g. HAProxy for Load balancing, concrete versions
- Scaling Services


# Cavets
* has been tested on Docker 1.12.1
* has been tested on os-x 10.10 & 10.11
* scripts will create machines based on the vmwarefusion driver. If you don't have that, then you will need to make some changes
* because boot2docker.iso is used, the locations of files will change if you use Ubuntu or something else. 
