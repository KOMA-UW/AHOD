#!/bin/bash
./build.sh
../db/build.sh

export TLSCERT=/etc/letsencrypt/live/api.payinpayout.tech/fullchain.pem
export TLSKEY=/etc/letsencrypt/live/api.payinpayout.tech/privkey.pem

export MYSQL_ROOT_PASSWORD=password
export MYSQL_DATABASE=messagesDB
export MYSQL_ADDR=messagesMYSQLDB:3306
export DSN="root:$MYSQL_ROOT_PASSWORD@tcp\(messagesMYSQLDB:3306\)/messagesDB"

export SESSIONKEY="sessionkey"
export REDISADDR=redisServer:6379
export GROUPADDR=groups:80
export MESSAGESADDR=messaging:80


ssh -i ~/.ssh/aws-capstone-2019.pem ec2-user@54.191.200.168 'bash -s'<< EOF
    

    docker rm -f gateway
    docker rm -f messagesMYSQLDB
    docker rm -f redisServer
    docker rm -f groupdb

    docker network rm ahodnet

    docker network create ahodnet
    
    docker pull uwkoma/koma-mysql

    docker pull uwkoma/gateway

    docker run -d --name redisServer \
    --network ahodnet \
    redis

    docker run -d \
    --name messagesMYSQLDB \
    --network ahodnet \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -v /my/own/datadir:/var/lib/mysql \
    uwkoma/koma-mysql

    sleep 20

    docker run -d \
    --name gateway \
    --network ahodnet \
    -p 443:443 \
    -v /etc/letsencrypt:/etc/letsencrypt:ro \
    -e DSN=$DSN \
    -e REDISADDR=$REDISADDR \
    -e SESSIONKEY=$SESSIONKEY \
    -e TLSCERT=$TLSCERT \
    -e TLSKEY=$TLSKEY \
    -e GROUPADDR=$GROUPADDR \
    -e MESSAGESADDR=$MESSAGESADDR \
    uwkoma/gateway

EOF
