FROM alpine:3.1
MAINTAINER Michal Cichra <michal.cichra@gmail.com>

ENV STORAGE=/mnt/storage
RUN adduser transmission -h ${STORAGE} -D \
 && mkdir /var/run/sshd

RUN apk add --update transmission-cli transmission-daemon  supervisor openssh ruby ruby-json ruby-io-console  \
 && rm -rf /var/cache/apk/*

ENV PRSS_VERSION=0.2.1 TRANSMISSION_RSS_VERSION=0.1.25
RUN gem install prss --version=${PRSS_VERSION} --no-document \
 && gem install transmission-rss --version=${TRANSMISSION_RSS_VERSION} --no-document

ADD supervisord.conf /etc/supervisor.d/transmission.ini
ADD sshd_config /etc/ssh/sshd_config

WORKDIR /mnt/storage/

ENV TRANSMISSION_RSS_CONFIG=${STORAGE}/watch/rss.yml \
    TRANSMISSION_CONFIG=${STORAGE}/.config \
    PRSS_CONFIG=${STORAGE}/watch/prss-key \
    PRSS_OUTPUT=${STORAGE}/watch

CMD ["/usr/bin/supervisord"]

EXPOSE 22 9091 51413
