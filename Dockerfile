FROM alpine:latest

ARG STORAGE=/mnt/storage

RUN adduser transmission -h ${STORAGE} -D \
 && mkdir /var/run/sshd

RUN apk add --update transmission-cli transmission-daemon  supervisor openssh ruby ruby-json ruby-io-console py3-pip \
 && rm -rf /var/cache/apk/*

ARG PRSS_VERSION=0.2.3
ARG FLEXGET_VERSION=3.0.19

RUN gem install prss --version=${PRSS_VERSION} --no-document \
 && pip3 install flexget==${FLEXGET_VERSION} transmissionrpc

RUN chmod a+r -R /usr/lib/ruby/gems

ADD supervisord.conf /etc/supervisor.d/transmission.ini
ADD sshd_config /etc/ssh/sshd_config

WORKDIR ${STORAGE}

ENV XDG_CONFIG_HOME=${STORAGE}/.config \
    TRANSMISSION_CONFIG=${STORAGE}/.config \
    PRSS_CONFIG=${STORAGE}/watch/prss-key \
    PRSS_OUTPUT=${STORAGE}/watch

RUN mkdir -p ${PRSS_OUTPUT} ${XDG_CONFIG_HOME} \
 && chown transmission:transmission -R ${STORAGE}

CMD ["/usr/bin/supervisord"]

EXPOSE 22 9091 51413 3539
