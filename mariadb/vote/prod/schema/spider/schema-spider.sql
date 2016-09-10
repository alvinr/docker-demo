create database if not exists test;

create or replace user sharded identified by "sharding";

GRANT ALL PRIVILEGES ON test.* to sharded;
flush PRIVILEGES;

drop server if exists shard1;
drop server if exists shard2;

CREATE SERVER shard1 FOREIGN DATA WRAPPER mysql 
    OPTIONS( 
    HOST 'prod_mariadb-shard1_1',
    DATABASE 'test',
    USER 'sharded',
    PASSWORD 'sharding',
    PORT 3306);

CREATE SERVER shard2 FOREIGN DATA WRAPPER mysql 
    OPTIONS( 
    HOST 'prod_mariadb-shard2_1',
    DATABASE 'test',
    USER 'sharded',
    PASSWORD 'sharding',
    PORT 3306);

create or replace 
    table test.votes(
        voter_id int, 
        ts bigint, 
        vote varchar(1),
        primary key(voter_id, ts))
    ENGINE=spider
    COMMENT='wrapper "mysql", table "votes"'
    PARTITION BY HASH (voter_id)
      (PARTITION part1 comment = 'srv "shard1"',
       PARTITION part2 comment = 'srv "shard2"');

create or replace table
    test.vote_history(
      voter_id int, 
      ts bigint, 
      vote varchar(1),
      primary key(voter_id, ts))
    ENGINE=spider
    COMMENT='wrapper "mysql", table "vote_history"'
    PARTITION BY HASH (voter_id)
      (PARTITION part1 comment = 'srv "shard1"',
       PARTITION part2 comment = 'srv "shard2"');

create or replace table
    test.summary(category varchar(50) primary key,
                 total int);