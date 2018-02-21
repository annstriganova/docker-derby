FROM ubuntu:16.04

ENV dbuser="axibase"
ENV dbpass="axibase"
ENV dbname="dbname"
ENV dbport=1527
ENV version=10.14.1.0
ENV DERBY_HOME=/opt/derby/db-derby-${version}-bin
ENV DERBY_LOG=${DERBY_HOME}/logs

USER root

RUN apt-get update && apt-get install -y wget \
	&& apt-get install -y openjdk-8-jdk \
	&& wget -q -P /opt/derby/  http://apache-mirror.rbc.ru/pub/apache//db/derby/db-derby-${version}/db-derby-${version}-bin.tar.gz \
	&& tar -xf /opt/derby/db-derby-${version}-bin.tar.gz -C /opt/derby/ \
	&& rm -Rf /opt/derby/db-derby-${version}-bin.tar.gz \
	&& mkdir ${DERBY_LOG}

ADD entrypoint.sh /

EXPOSE 1527

ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]