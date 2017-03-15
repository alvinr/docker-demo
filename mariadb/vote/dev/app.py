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
import os.path

option_a = os.getenv('OPTION_A', "Coke")
option_b = os.getenv('OPTION_B', "Pepsi")
option_c = os.getenv('OPTION_C', "Tap Water")
hostname = socket.gethostname()

app = Flask(__name__)
db = None

host = socket.gethostbyname(hostname)

record_vote = (
  "INSERT INTO votes (voter_id, vote) "
  "VALUES (%s, %s)" 
  "ON DUPLICATE KEY update vote=%s")
insert_vote_history = (
  "INSERT INTO vote_history (voter_id, vote) "
  "VALUES (%s, %s)" )
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
    secrets_fn=os.environ.get("APP_PASSWORD_FILE", "")
    app.logger.error(secrets_fn)
    if os.path.isfile(secrets_fn):
      with open(secrets_fn, 'r') as myfile:
        passwd=myfile.read().replace('\n', '')
    else:
        passwd=os.environ.get("APP_PASSWORD","none")

    db = mariadb.connect(host=os.environ.get("APP_MARIADB_HOST", "localhost"),
                         user=os.environ.get("APP_USER","root"),
                         passwd=passwd,
                         db=os.environ.get("APP_DATABASE","test"))

    cursor=db.cursor()

    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = "a"

    if request.method == 'POST':
        vote = request.form['vote']

    cursor.execute(record_vote, (voter_id, vote, vote))
    cursor.execute(insert_vote_history, (voter_id, vote))
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
