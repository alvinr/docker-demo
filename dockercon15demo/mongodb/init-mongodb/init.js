function initReplSet(cfg) {

   db = connect(cfg["members"][0]["host"]+"/admin");
   rs.initiate(cfg);

   while (rs.status().startupStatus || (rs.status().hasOwnProperty("myState") && rs.status().myState != 1)) { sleep(1000); }

}

cfg_rs1 = {
	_id: "rs1",
	members: [
		{ _id: 0,
		  host: "mongodb_rs1a_1:27017",
		  priority: 10
		},
		{ _id: 1,
		  host: "mongodb_rs1b_1:27017",
		  priority: 1
		},
		{ _id: 2,
		  host: "mongodb_rs1c_1:27017",
		  arbiterOnly: true
		}
	]
}

cfg_rs2 = {
	_id: "rs2",
	members: [
		{ _id: 0,
		  host: "mongodb_rs2a_1:27017",
		  priority: 10
		},
		{ _id: 1,
		  host: "mongodb_rs2b_1:27017",
		  priority: 1
		},
		{ _id: 2,
		  host: "mongodb_rs2c_1:27017",
		  arbiterOnly: true
		}
	]
}

initReplSet(cfg_rs1);
initReplSet(cfg_rs2);

#sleep(5000);

db = connect("mongodb_mongodb_1:27017/admin");

sh.addShard("rs1/mongodb_rs1a_1:27017,mongodb_rs1b_1:27017");
sh.addShard("rs2/mongodb_rs2a_1:27017,mongodb_rs2b_1:27017");

sh.enableSharding("test");
sh.shardCollection("test.hits", { _id : "hashed" });
