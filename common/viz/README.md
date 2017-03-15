# Docker Swarm Visualization

## Running - new stack version

```
docker stack deploy viz -c docker-compose.stack.yml
```

## Running - old compose version

This assumes you have created your Swarm with Machine and the master is called `swarm-0`.

```
source scripts/setup.sh
scripts/up.sh swarm-0
```

Browse to http://localhost:3000 to see the console. Add url parameter multiply=true to multiply the number of ocntainers and hosts for testing. http://localhost:3000/?multiply=true. When you use multuply, use cmd-- to reduce size of display, uses 2000 pix for svg viewport width. I tested it with 100 hosts and 12000 containers.

<img src="../static/viz-demo.png"></img>
