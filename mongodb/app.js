
db = db.getSisterDB("admin")
sh.addShard("rs1/192.168.99.113:28003,192.168.99.112:28002,192.168.99.114:28001")
sh.addShard("rs2/192.168.99.113:29001,192.168.99.114:29002,192.168.99.112:29003")
sh.enableSharding("test")
sh.shardCollection("test.blogs", { _id : "hashed" })
db = db.getSisterDB("test")
var buf=""
for (i=0; i < 1024; i++) { buf+="A"; }
for (i=0; i < 10000; i++) { db.blogs.insert({name: i, ts: new Date(), text: buf});}
