#!/bin/bash

#We're run by Marathon, and don't have links to other containers
#sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZK_PORT_2181_TCP_ADDR/g" $KAFKA_HOME/config/server.properties

#There's only 1 port when we're run by Marathon, not separate ports inside & outside the Docker container
# export KAFKA_ADVERTISED_PORT=$(docker port `hostname` 9092 | sed -r "s/.*:(.*)/\1/g")

#When Marathon chooses a random port for this task, it provides that in PORT0
export KAFKA_PORT=$PORT0

#HOST should be set to the Mesos slave's host name, and clients should be able to resolve & connect to it; in fig-mesos this is "localdocker"
#HOSTNAME in fig-mesos this is the Mesos slave docker container's hostname/containerId
export KAFKA_HOST_NAME=$HOST
export KAFKA_ADVERTISED_HOST_NAME=$HOST

#Using this port for broker.id is sorta ok, except if Marathon runs multiple brokers on separate nodes with the same ports, we'll get a collision
#I don't see that Marathon provides any other unique enough integers in env vars for us to use though
#One possible solution would be to treat separate brokers as separate apps in marathon, and assign each one a unique broker.id in the json file
# - this isn't very DRY so that sucks :(
# - can't use Marathon's scaling :(
# - lose ability to do hostname:UNIQUE :( :( :(
# - broker.id would remain constant if broker moves to a new node though
# - have a launch script that queries Marathon for # of existing Kafkas, then uses broker.id=n+1
#Could you hash hostname:port or something? Although I think the purpose of broker.id is for it to remain constant even when broker moves to another node though
#If we rolled our own Mesos framework, the Scheduler would manage the broker.id for us
# ==> for now assume that the Marathon json will contain a unique KAFKA_BROKER_ID
#https://github.com/brndnmtthws/kafka-on-marathon/blob/master/run-kafka.rb
# - it appears that run-kafka.rb is what marathon runs, and it starts that kafka broker
# - one of its purposes is to check zookeeper to see if any desired brokers don't exist yet, before launching a broker
# - marathon must tell it how many desired brokers there are (and a human presumably tells marathon that number)
# => if zk doesn't have enough registered brokers yet, then this script chooses a broker.id based on that, and starts a broker
# - it's also doing zk leader election, so only 1 of these in the mesos cluster starts a broker at a time
# - we could build something similar that runs when the docker container starts to compute the broker.id:
#   - wait for zk leader election
#   - query kafka brokers in zk to see if we any more are needed (shouldn't this always be true?)
#   - broker.id = brokerCount + 1
#export KAFKA_BROKER_ID=$KAFKA_PORT

#create the zk chroot path if necessary, because kafka doesn't create it
zkConnect=`echo $KAFKA_ZOOKEEPER_CONNECT | sed -r "s@(.*)/.*@\1@g"`    #assumes there's always a chroot path
zkChrootPath=`echo $KAFKA_ZOOKEEPER_CONNECT | sed -r "s@.*/(.*)@\1@g"` #assumes there's always a chroot path
if ! zookeepercli -servers $zkConnect -c exists "/$zkChrootPath"
then
  zookeepercli -servers $zkConnect -c create "/$zkChrootPath" ""
  echo "Created /$zkChrootPath chroot path"
fi

env #debugging

#TODO There's a bug in this code: if the env var value contains forward slashes, the replacement does not work!
for VAR in `env`
do
  if [[ $VAR == KAFKA_* ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    if [[ $kafka_name != 'home' ]]; then
      env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
      if grep -q "$kafka_name" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties
      else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
      fi
     fi
  fi
done

cat $KAFKA_HOME/config/server.properties #debugging

if [ "$KAFKA_HEAP_OPTS" != "" ]; then
    sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
fi

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
