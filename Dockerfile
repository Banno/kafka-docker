FROM ubuntu:trusty

MAINTAINER Wurstmeister 

RUN apt-get update; apt-get install -y unzip  openjdk-6-jdk wget git docker.io

RUN wget -q http://mirror.gopotato.co.uk/apache/kafka/0.8.1.1/kafka_2.8.0-0.8.1.1.tgz -O /tmp/kafka_2.8.0-0.8.1.1.tgz
RUN tar xfz /tmp/kafka_2.8.0-0.8.1.1.tgz -C /opt

RUN wget -q https://github.com/outbrain/zookeepercli/releases/download/v1.0.4/zookeepercli_1.0.4_amd64.deb -O /tmp/zookeepercli_1.0.4_amd64.deb
RUN dpkg -i /tmp/zookeepercli_1.0.4_amd64.deb
RUN rm /usr/bin/zookeepercli-1.0.4-1.x86_64.rpm

ENV KAFKA_HOME /opt/kafka_2.8.0-0.8.1.1
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
CMD start-kafka.sh 
