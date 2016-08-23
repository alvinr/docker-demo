create database test;
use test
create table votes(voter_id int, 
                   ts bigint, 
                   vote varchar(1),
                   primary key(voter_id, ts));
create table summary(category varchar(50) primary key,
                     total int);
