FROM alpine:3.1
MAINTAINER Michal Cichra <michal.cichra@gmail.com>

ENV STORAGE=/mnt/storage
RUN adduser transmission -h ${STORAGE} -D \
 && mkdir /var/run/sshd

RUN apk add --update transmission-cli transmission-daemon  supervisor openssh ruby ruby-json ruby-io-console py-pip \
 && rm -rf /var/cache/apk/*

ENV PRSS_VERSION=0.2.2 TRANSMISSION_RSS_VERSION=0.1.25 FLEXGET_VERSION=1.2.495
RUN gem install prss --version=${PRSS_VERSION} --no-document \
 && gem install transmission-rss --version=${TRANSMISSION_RSS_VERSION} --no-document \
 && pip install flexget==${FLEXGET_VERSION} transmissionrpc

# patch https://github.com/nning/transmission-rss/pull/22
ADD https://raw.githubusercontent.com/mikz/transmission-rss/112edb2430c16505c9b1e97188d8ab4ec33d7fe3/lib/transmission-rss/feed.rb \
    /usr/lib/ruby/gems/2.1.0/gems/transmission-rss-0.1.25/lib/transmission-rss/feed.rb

RUN chmod a+r -R /usr/lib/ruby/gems

ADD supervisord.conf /etc/supervisor.d/transmission.ini
ADD sshd_config /etc/ssh/sshd_config

WORKDIR /mnt/storage/

ENV TRANSMISSION_RSS_CONFIG=${STORAGE}/watch/rss.yml \
    XDG_CONFIG_HOME=${STORAGE}/.config \
    TRANSMISSION_CONFIG=${STORAGE}/.config \
    PRSS_CONFIG=${STORAGE}/watch/prss-key \
    PRSS_OUTPUT=${STORAGE}/watch

RUN mkdir -p ${PRSS_OUTPUT} ${XDG_CONFIG_HOME} \
 && chown transmission:transmission -R ${STORAGE}

CMD ["/usr/bin/supervisord"]

EXPOSE 22 9091 51413 3539
