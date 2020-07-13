FROM alpine:latest

ARG S6_VERSION=latest
RUN set -xe \
    && apk add --no-cache --purge -uU curl \
    && VERSION=$(curl -SL https://api.github.com/repos/just-containers/s6-overlay/releases/${S6_VERSION} | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_v__') \
    && echo "using s6 version: ${VERSION}" \
	&& curl -o /tmp/s6-overlay-amd64.tar.gz -jkSL https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-amd64.tar.gz \
	&& tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
	&& apk del --purge curl \
	&& rm -rf /var/cache/apk/* /tmp/*

ARG STORAGE=/mnt/storage

RUN adduser transmission -h ${STORAGE} -D \
 && mkdir /var/run/sshd

RUN apk add --update transmission-cli transmission-daemon ruby ruby-json ruby-io-console py3-pip \
 && rm -rf /var/cache/apk/*

ARG PRSS_VERSION=0.2.3
ARG FLEXGET_VERSION=3.1.66

RUN gem install prss --version=${PRSS_VERSION} --no-document \
 && pip3 install --ignore-installed six flexget==${FLEXGET_VERSION} transmissionrpc

RUN chmod a+r -R /usr/lib/ruby/gems

WORKDIR ${STORAGE}
ENV HOME ${STORAGE}

ENV XDG_CONFIG_HOME=${STORAGE}/.config \
    TRANSMISSION_CONFIG=${STORAGE}/.config \
    PRSS_CONFIG=${STORAGE}/watch/prss-key \
    PRSS_OUTPUT=${STORAGE}/watch

RUN mkdir -p ${PRSS_OUTPUT} ${XDG_CONFIG_HOME} \
 && chown transmission:transmission -R ${STORAGE}

COPY services.d /etc/services.d/

CMD ["/init"]

EXPOSE 22 9091 51413 3539
