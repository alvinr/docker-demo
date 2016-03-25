from flask import Flask
from flask import render_template
from flask import request
from flask import make_response
import os
import socket
import random
import json
import time
import aerospike

option_a = os.getenv('OPTION_A', "Coke")
option_b = os.getenv('OPTION_B', "Pepsi")
option_c = os.getenv('OPTION_C', "Tap Water")
hostname = socket.gethostname()

app = Flask(__name__)

config = {
  'hosts': [ (os.environ.get('AEROSPIKE_HOST', 'prod_aerospike_1'), 3000) ],
  'policies': { 'key': aerospike.POLICY_KEY_SEND }
}

host = socket.gethostbyname(hostname)

@app.route("/env", methods=['GET'])
def dump_env():
    s = ''
    for key in os.environ.keys():
        s = "%s%30s=%s\n" % (s, key,os.environ[key])
    resp = make_response(render_template(
	    'env.html',
	    s=s
    ))
    return resp

@app.route("/", methods=['POST','GET'])
def index():

    if aerospike.client(config).is_connected()==False:
        client = aerospike.client(config).connect()

    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = "a"

    if request.method == 'POST':
        vote = request.form['vote']

    time_ms = long(time.time()*1000)

    key = ("test", "votes", voter_id)

    operations = [
        {
            "op" : aerospike.OPERATOR_WRITE,
            "bin" : "vote",
            "val" : vote
        },
        {
            "op" : aerospike.OPERATOR_WRITE,
            "bin" : "ts",
            "val" : time_ms
        },
        {
            "op" : aerospike.OPERATOR_WRITE,
            "bin" : "voter_id",
            "val" : voter_id
        },
        {
            "op" : aerospike.OP_LIST_APPEND,
            "bin" : "history",
            "val" : {'vote': vote, 'ts': time_ms}
        }
    ]
    client.operate(key, operations)

    client.increment(("test", "summary", "total_votes"), "total", 1)
    client.increment(("test", "summary", host), "total", 1) 

    resp = make_response(render_template(
        'index.html',
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        hostname=hostname,
	    node=host,
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp


if __name__ == "__main__":
	app.run(host='0.0.0.0', debug=True)
