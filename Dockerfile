FROM ubuntu:14.04
MAINTAINER Wurstmeister

RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y openjdk-6-jdk wget

RUN wget -q http://mirror.gopotato.co.uk/apache/kafka/0.8.1.1/kafka_2.8.0-0.8.1.1.tgz -O /tmp/kafka_2.8.0-0.8.1.1.tgz
RUN tar xfz /tmp/kafka_2.8.0-0.8.1.1.tgz -C /opt
RUN mv /opt/kafka_2.8.0-0.8.1.1 /opt/kafka/

ENV KAFKA_HOME /opt/kafka
ADD scripts/start-kafka.sh /opt/kafka/bin/start-kafka.sh
CMD ["/opt/kafka/bin/start-kafka.sh"]
