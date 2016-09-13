create database if not exists test;

create or replace user sharded identified by "sharding";

GRANT ALL PRIVILEGES ON test.* to sharded;
/*
GRANT SUPER on *.* to sharded;
grant all on test.* to "sharded"@"172.17.0.2" identified by "sharding"; 
*/
grant super on *.* to "sharded"@"%" identified by "sharding"; 
flush PRIVILEGES;

create or replace 
    table test.votes(
        voter_id int, 
        vote varchar(1),
        primary key(voter_id));

create or replace 
    table test.vote_history(
        voter_id int, 
        ts bigint, 
        vote varchar(1),
        primary key(voter_id, ts));