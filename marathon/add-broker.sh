#!/bin/bash

#Currently this script really only works for running the very first Kafka broker on a fresh new Mesos cluster, not for adding more brokers

#Note: you should `docker pull registry.banno-internal.com/kafka:3` on all Mesos slaves before running this script, otherwise the Kafka task will sit in State=STAGING for a long time

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR=$(dirname $DIR)
MARATHON_DIR=$BASE_DIR/marathon

#if the json file has KAFKA_ZOOKEEPER_CONNECT with a chroot path, make sure it exists in Zookeeper
docker run registry.banno-internal.com/zookeepercli:1.0.4 -servers localdocker -c create /kafka ""
echo "Created /kafka znode"

#get largest brokerId from Zookeeper and replace KAFKA_BROKER_ID=n+1 in the json file

#create application in Marathon using json
$MARATHON_DIR/create-app.sh $MARATHON_DIR/kafka1.json
