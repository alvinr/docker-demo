from flask import Flask, request
import aerospike
import os
import datetime
import socket
import uuid

app = Flask(__name__)

config = {
  'hosts': [ (os.environ.get('AEROSPIKE_HOST', 'aerospike_aerospike_1'), 3000) ]
}

host = socket.gethostbyname(socket.gethostname())

@app.route('/')
def hello():

    try:

        
        if aerospike.client(config).is_connected()==False:
            client = aerospike.client(config).connect()

        foo = str(uuid.uuid1());

        #key = ("test", "hits", foo)
        # Insert the 'hit' record
        client.put(("test", "hits", foo), {"server": host, "ts": datetime.datetime.utcnow()} )

        # Maintain our summaries for the grand total and for each server
        #key = ("test", "summary", "total_hits")
        client.increment(("test", "summary", "total_hits"), "total", 1)

        #key = ("test", "summary", host)
        client.increment(("test", "summary", host), "total", 1)
        
        (key, meta, bins) = client.get(("test","summary","total_hits"))
        
        # Return the updated web page
        return "Hello World! I have been seen by %s." % bins["total"]

    except Exception as e:
        return "Hummm - %s looks like we have an issue, let me try again" % "err: {0}".format(e)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
