import docker
from docker import Client
import pprint
from pymongo import MongoClient

kw = docker.utils.kwargs_from_env()
kw['tls'].verify = False
cli = Client(**kw)

containers = cli.containers()

shards = {}
configs = {}
switches = {}
rs_hosts = {}


# Inspect the containers for the MongoDB processes , building a dictioary of IP and Ports
for c in containers:
	Id = c['Id']
	details = cli.inspect_container(Id)
	name = details['Name']
	
	node = {}
	node['IPAddress'] = details['NetworkSettings']['IPAddress']
	node['Ports'] = details['NetworkSettings']['Ports']

	labels = details['Config']['Labels']

	for k in labels:
		if ( k  == 'com.docker.examples.mongodb.role' ) :
			if ( labels[k] == "mongod" ):
				node['Priority'] = details['Config']['Labels']['com.docker.examples.mongodb.mongod.priority']
				shard_name = labels['com.docker.examples.mongodb.mongod.replset']
				shards.setdefault(shard_name,[]).append(node)
			elif ( labels[k] == "mongoc" ):
				configs[name] = node
			elif ( labels[k] == "mongos" ):
				switches[name] = node 			

pp = pprint.PrettyPrinter(indent=4)

# Construct the ReplSet cfg
for shard in shards:
	cfg = {}
	cfg['_id'] = shard
	cfg['members'] = []
	_id=0
	conn_str=""
	rs_str=shard + "/"
	for node in shards[shard]:
		
		member = {}
		member['_id'] = _id
		for l in node['Ports']:
			internal_port = node['Ports'][l]
			for m in internal_port: 
				port = m['HostPort']
				hostname = m['HostIp']
				conn_str=hostname + ":" + port
			conn_str=hostname + ":" + port
		rs_str+=conn_str + ","
		member['host'] = conn_str
		member['priority'] = int(node['Priority'])
		if ( member['priority'] == 0 ):
			member['arbiterOnly'] = True
		cfg['members'].append(member)
		_id+=1
	rs_hosts[shard] = rs_str.rstrip(",")

	# contact the ReplSet and initiate the set
	host=""
	for node in cfg['members']:
		if ( node['priority'] == 10 ):
			host = node['host']
			break

	client = MongoClient(host)

	db = client['admin']
	rsi = {}
	rsi['replSetInitiate'] = cfg
	pp.pprint(cfg)
	db.command(rsi)


# Build the yaml file for the config servers and mongos

config_svr=""
i=0
config_hosts = []
for config in configs:
	node = configs[config]
	internal_port = node['Ports']
	for m in internal_port: 
		host = internal_port[m][0]
		port = host['HostPort']
		hostname = host['HostIp']
		conn_str=hostname + ":" + port
		config_hosts.append(conn_str)

mongos_yaml_template = '''
mongos1:
  image: alvinr/mongos
  ports: 
    - "27017:27017"
  command: --configdb %(config_hosts)s
  labels:
    - "com.docker.examples.mongodb.role=mongos"
  environment:
    - "affinity:com.docker.examples.mongodb.role!=mongod"
    - "affinity:com.docker.examples.mongodb.role!=mongoc"
''' % {'config_hosts' : ("".join(["," + node for node in config_hosts])).lstrip(",")}	
switch_yaml_file = open("switch.yaml", 'w')
switch_yaml_file.write(mongos_yaml_template)
switch_yaml_file.close()

# Shell yaml file
app_yaml_template = '''
app:
  image: alvinr/mongo
  ports: 
    - "27017:27017"
  volumes: 
    - /data/docker:/data/scripts
  command: -i -t %(switch_host)s
  labels:
    - "com.docker.examples.mongodb.app=true"
  environment:
    - "affinity:com.docker.examples.mongodb.role==mongos"
''' % {'switch_host' : ("".join(["," + node for node in config_hosts])).lstrip(",")}	
app_yaml_file = open("app.yaml", 'w')
app_yaml_file.write(app_yaml_template)
app_yaml_file.close()

# Build the js file for the app
mongo_app_template = '''
db = db.getSisterDB("admin")
sh.addShard("%(rs1_hosts)s")
sh.addShard("%(rs2_hosts)s")
sh.enableSharding("test")
sh.shardCollection("test.blogs", { _id : "hashed" })
db = db.getSisterDB("test")
var buf=""
for (i=0; i < 1024; i++) { buf+="A"; }
for (i=0; i < 5000; i++) { db.blogs.insert({name: i, ts: new Date(), text: buf});}
''' % {'rs1_hosts': rs_hosts['rs1'],
       'rs2_hosts': rs_hosts['rs2']}
app_js_file = open("app.js", 'w')
app_js_file.write(mongo_app_template)
app_js_file.close()

# Build the yaml file for the application
#target = open("app.yaml", 'w')
#for config in configs:
#	for node in config:
#		hostname=k['IPAddress']
#		for l in node['Ports']:
#			port = l.replace('/tc[','')
#			conn_str=hostname + ":"" + port
#			config_svr += conn_str + ","