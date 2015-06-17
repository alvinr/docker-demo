
db = db.getSisterDB("admin")
sh.addShard("rs1/192.168.99.123:28001,192.168.99.122:28003,192.168.99.121:28002")
sh.addShard("rs2/192.168.99.123:29001,192.168.99.122:29002,192.168.99.121:29003")
sh.enableSharding("test")
sh.shardCollection("test.blogs", { _id : "hashed" })
db = db.getSisterDB("test")
var buf=""
for (i=0; i < 1024; i++) { buf+="A"; }
for (i=0; i < 5000; i++) { db.blogs.insert({name: i, ts: new Date(), text: buf});}
