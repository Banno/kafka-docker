kafka-docker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)

The image is available directly from https://index.docker.io

## Quickstart

```
export START_SCRIPT=https://raw2.github.com/wurstmeister/kafka-docker/master/start-broker.sh
curl -Ls $START_SCRIPT | bash /dev/stdin 1 9092 <your-host-ip>
```

Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers.

## Environmental Variables

- `BROKER_ID` (example `1`)
- `HOST_IP` (example`192.168.59.103`)
- `PORT` (example: `9092`)
- `KAFKA_HEAP_OPTS`

## Steps

__build__

```
docker build -t registry.banno-internal.com/kafka .
```

## Tutorial

[http://wurstmeister.github.io/kafka-docker/](http://wurstmeister.github.io/kafka-docker/)
