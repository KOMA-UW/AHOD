create table if not exists user (
    id int not null auto_increment primary key,
    email varchar(128) not null unique,
    passhash binary(64) not null,
    username varchar(255) not null,
    firstname varchar(64) not null,
    lastname varchar(128) not null,
    photourl varchar(128) not null
);