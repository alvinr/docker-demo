from flask import Flask, request
from pymongo import MongoClient, errors
import os
import datetime
import socket

app = Flask(__name__)
mongo = MongoClient(host=os.environ.get('MONGO_HOST', 'mongo'), port=27017,socketTimeoutMS=500,connectTimeoutMS=1000,socketKeepAlive=True)
host = socket.gethostbyname(socket.gethostname())
db = mongo['test']

@app.route('/')
def hello():

    try:

        # Insert the 'hit' record
        db.hits.insert( {"server": host, "ts": datetime.datetime.utcnow()} )

        # Maintain our summaries for the grand total and for each server
        db.summary.update_one( {"_id": "total_hits"}, {"$inc": {"total": 1}}, True )
        db.summary.update_one( {"_id": host}, {"$inc": {"total": 1}}, True )
        hit_count = db.summary.find_one( {"_id": "total_hits"}, { "_id": 0, "total": 1 } )["total"]
        
        # Return the updated web page
        return "Hello World! I have been seen by %s." % hit_count

    except errors.NetworkTimeout:
        return "Hummm - %s looks like the Network timedout, let me try again" % host
    except errors.AutoReconnect:
        return "Hummm - %s autoreconnect did not reconnect, let me try again" % host

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
