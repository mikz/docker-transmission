FROM alpine:latest

ARG S6_VERSION=v2.2.0.3
RUN set -xe \
    && apk add --no-cache --purge -uU curl \
	&& curl -o /tmp/s6-overlay-amd64.tar.gz -jkSL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
	&& tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
	&& apk del --purge curl \
	&& rm -rf /var/cache/apk/* /tmp/*

ARG STORAGE=/mnt/storage

RUN adduser transmission -h ${STORAGE} -D \
 && mkdir /var/run/sshd

RUN apk add --no-cache --purge --update transmission-cli transmission-daemon ruby ruby-json ruby-io-console flexget \
 && rm -rf /var/cache/apk/*

ARG PRSS_VERSION=0.2.4

RUN apk add --no-cache --purge -uU build-base linux-headers python3-dev \
 && gem install prss --version=${PRSS_VERSION} --no-document \
 && apk del --purge build-base linux-headers python3-dev \
 && rm -rf /var/cache/apk/* /tmp/*

RUN chmod a+r -R /usr/lib/ruby/gems

WORKDIR ${STORAGE}
ENV HOME=${STORAGE}

ENV XDG_CONFIG_HOME=${STORAGE}/.config \
    TRANSMISSION_CONFIG=${STORAGE}/.config \
    PRSS_CONFIG=${STORAGE}/watch/prss-key \
    PRSS_OUTPUT=${STORAGE}/watch

RUN mkdir -p ${PRSS_OUTPUT} ${XDG_CONFIG_HOME} \
 && chown transmission:transmission -R ${STORAGE}

COPY services.d /etc/services.d/

CMD ["/init"]

EXPOSE 22 9091 51413 3539
