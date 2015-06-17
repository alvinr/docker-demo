# docker-demo
Demo's for Docker
# mongodb
This will build a shareded cluster, backed with two replica sets with three memebrs each

## Instructions

See prov.sh

Create a machine in order to do the work from

```
docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc1/boot2docker.iso dev2
eval "$(docker-machine env dev2)"
```

Generate the Swarm token

```
docker run --rm swarm create 
483461990bff729ff6d7e57316a5ad10

sid=483461990bff729ff6d7e57316a5ad10
```

Start the Swarm master

```
docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc4/boot2docker.iso --swarm-image "swarm:0.3.0-rc2" --swarm --swarm-master --swarm-discovery token://$sid mongodb-swarm
```

Start the other docker hosts that represent the cluster

```
eval "$(docker-machine env --swarm mongodb-swarm)"

docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc4/boot2docker.iso --swarm-image "swarm:0.3.0-rc2" --swarm --swarm-discovery token://$sid mongodb-server1

docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc4/boot2docker.iso --swarm-image "swarm:0.3.0-rc2" --swarm --swarm-discovery token://$sid mongodb-server2 

docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/tianon/boot2docker/releases/download/v1.7.0-rc4/boot2docker.iso --swarm-image "swarm:0.3.0-rc2" --swarm --swarm-discovery token://$sid mongodb-server3
```

Start all the containers that represent the memebrs of the relica sets and the config servers
- rs1 - memebers s1rs1a, s1rs1b, s1rs1c
- rs2 - memebers s2rs2a, s2rs2a, s2rs2a
- confi1, config2, config3

```
docker-compose -f mdb.yaml up
```

See the containers

```
docker ps
```

Run the pythion script to build the ReplicaSet config and initaite the sets

```
python mdb.py
```

Run the generated yaml file to start the mongos (switch process)

```
docker-compose -f switch.yaml up
```

Copy the script that will build the sharded system and insert some data

```
docker-machine scp app.js mongodb-swarm:/home/docker/
```

Finally run the mongo shell with the script

```
docker run -t -i -v /home/docker:/data/scripts -e "affinity:com.docker.examples.mongodb.mongos==true" --name app alvinr/mongo 192.168.99.111:32017 /data/scripts/app.js
```

