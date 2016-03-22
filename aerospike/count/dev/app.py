from flask import Flask, request, make_response, render_template
import aerospike
import os
import datetime
import time
import socket
import uuid

app = Flask(__name__)

config = {
  'hosts': [ (os.environ.get('AEROSPIKE_HOST', 'prod_aerospike_1'), 3000) ],
  'policies': { 'key': aerospike.POLICY_KEY_SEND }
}

hostname = socket.gethostname()
host = socket.gethostbyname(hostname)



@app.route('/')
def hello():

    try:

        
        if aerospike.client(config).is_connected()==False:
            client = aerospike.client(config).connect()

        foo = str(uuid.uuid1());

        #key = ("test", "hits", foo)
        # Insert the 'hit' record
        # ts = datetime.datetime.utcnow()
        ts =  int(round(time.time() * 1000))
        client.put(("test", "hits", foo), {"server": host, "ts": ts} )

        # Maintain our summaries for the grand total and for each server
        #key = ("test", "summary", "total_hits")
        client.increment(("test", "summary", "total_hits"), "total", 1)

        #key = ("test", "summary", host)
        client.increment(("test", "summary", host), "total", 1)
        
        (key, meta, bins) = client.get(("test","summary","total_hits"))
        
        # Return the updated web page
        #return "Hello World! I have been seen by %s." % bins["total"]

        resp = make_response(render_template(
            'index.html',
            counter=bins["total"],
            hostname=hostname,
            node=host
        ))

        return resp

    except Exception as e:
        return "Hummm - %s looks like we have an issue, let me try again" % "err: {0}".format(e)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
