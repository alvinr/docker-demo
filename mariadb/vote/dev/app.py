from flask import Flask
from flask import render_template
from flask import request
from flask import make_response
import os
import socket
import random
import json
import time
import MySQLdb as mariadb

option_a = os.getenv('OPTION_A', "Coke")
option_b = os.getenv('OPTION_B', "Pepsi")
option_c = os.getenv('OPTION_C', "Tap Water")
hostname = socket.gethostname()

app = Flask(__name__)
db = None

host = socket.gethostbyname(hostname)

insert_vote = (
  "INSERT INTO votes (voter_id, ts, vote) "
  "VALUES (%s, %s, %s)" )
update_summary = (
  "INSERT INTO summary (category, total) "
  "VALUES (%s, %s) "
  "ON DUPLICATE KEY "
  "UPDATE total = total + 1" )

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

     #    if ((db is None) or (db.is_connected()==False)):
    db = mariadb.connect(host=os.environ.get("MARIADB_HOST", "prod_mariadb_1"),
                         user="root",
                         passwd="foo",
                         db="test")

    cursor=db.cursor()

    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = "a"

    if request.method == 'POST':
        vote = request.form['vote']

    time_ms = long(time.time()*1000)
    app.logger.error('time %d', time_ms)

    cursor.execute(insert_vote, (voter_id, time_ms, vote))
    cursor.execute(update_summary, ("total_votes", 1))
    cursor.execute(update_summary, (host, 1))

    db.commit()

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
