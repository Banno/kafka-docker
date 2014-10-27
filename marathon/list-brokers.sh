#!/bin/bash

for broker in `docker run registry.banno-internal.com/zookeepercli:1.0.4 -servers dev.banno.com -c ls /kafka/brokers/ids`
do
  #{"jmx_port":-1,"timestamp":"1414246398084","host":"localdocker1","version":1,"port":31104}
  json=`docker run registry.banno-internal.com/zookeepercli:1.0.4 -servers dev.banno.com -c get /kafka/brokers/ids/$broker`
  echo $json
  #host=`echo $json | gsed -r 's@.*"host":"(.*)".*@\1@g'`
  #port=`echo $json | gsed -r 's@.*"port":(\d+).*@\1@g'`
done
