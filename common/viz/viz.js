var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = 3000;
var refreshTime = 2000;

app.get('/', function(req, res){
  res.sendFile(__dirname + '/static/index.html');
});

http.listen(port, function(){
  console.log('listening on *:3000');
});

var Docker = require('dockerode');
var fs = require('fs');

var dockerHost = process.env.SWARM_HOST.match(/tcp:\/\/(.*):.*$/)[1];
var dockerPort = process.env.SWARM_HOST.match(/tcp:\/\/.*:(.*)$/)[1];
var dockerCertPath = process.env.DOCKER_CERT_PATH;
console.log(dockerHost);
console.log(dockerPort);

var docker = new Docker({
  protocol: 'https', //you can enforce a protocol
  host: dockerHost,
  port: dockerPort,
  ca: process.env.SWARM_CA || fs.readFileSync(dockerCertPath + '/ca.pem'),
  cert: process.env.SWARM_CERT || fs.readFileSync(dockerCertPath + '/cert.pem'),
  key: process.env.SWARM_KEY || fs.readFileSync(dockerCertPath + '/key.pem')
});

function listContainers(callback) {
  var res = {hosts: {}};
  docker.listContainers({}, function (err, containers) {
    if (containers) {
      containers.forEach(function (containerInfo) {
        var names = containerInfo.Names;
        if (!names.length) {
          return;
        }

        var tokens = names[0].split('/');

        if (tokens.length < 2) {
          return;
        }
        var host = tokens[1];
        var name = tokens[2];
        var data = {
          id: containerInfo.Id,
          image: containerInfo.Image
        };

        if (name.indexOf('swarm-agent') >= 0) {
          if (!res.hosts[host]) {
            res.hosts[host] = [];
          }
          return;
        }

        if (host in res.hosts) {
          res.hosts[host].push(data);
        }
        else {
          res.hosts[host] = [data];
        }
      });
      callback(res);
    }
    setTimeout(function () {
      listContainers(callback);
    }, 1000);
  });
}

listContainers(function (containers) {
  io.emit('containers', containers);
});

// IF ABOVE IS STILL SLOW: make use of below to trigger based on events
/*
docker.getEvents(function (error, stream) {
  if (error) {
    throw new Error('Could not listen to Docker events');
  }

  stream.setEncoding('utf8');
  stream.on('data', function (json) {
    var data = JSON.parse(json);

    if (data.status === 'create') {
      console.log('Container created.');
      var container = {
        id: data.id,
        image: data.from.split(' ')[0]
      };
      var host = data.node.Name;
      if (data.node.Name in res.hosts) {
        res.hosts[host].push(container);
      } else {
        res.hosts[host] = [container];
      }
      io.emit('containers', res);
    } else if (data.status === 'destroy' || data.status === 'kill' || data.status === 'stop') {
      console.log('Container died.');
      var host = data.node.Name;
      console.log(host);
      console.log(res.hosts);
      if (res.hosts[host]) {
        res.hosts[host] = res.hosts[host].filter(function (container) {
          return container.id !== data.id;
        });
        io.emit('containers', res);
      }
    }
  });
});
*/
