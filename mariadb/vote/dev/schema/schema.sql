create database if not exists test;

create or replace 
    table test.votes(
        voter_id int, 
        vote varchar(1),
        primary key(voter_id));

create or replace 
    table test.vote_history(
        voter_id int, 
        ts timestamp(6) default now(), 
        vote varchar(1),
        primary key(voter_id, ts));

create or replace table 
    test.summary(
        category varchar(50) primary key,
        total int);
exit
