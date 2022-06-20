FROM alpine

LABEL MAINTAINER sagit <https://github.com/sagit-chu>

ARG TZ=Asia/Shanghai

RUN set -ex \
    && apk add --update --no-cache curl wget ca-certificates jq tzdata \
    && update-ca-certificates \
    && echo $TZ > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && date \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

ARG VER
ARG URL=https://github.com/fatedier/frp/releases/download/v${VER}/frp_${VER}_linux_amd64.tar.gz

RUN mkdir -p /frp \
    && cd /frp\
    && wget -qO- ${URL} | tar xz \
    && mv frp_*/frpc /usr/bin/ \
    && mv frp_*/frps /usr/bin/ \
    && mv frp_*/*.ini ./ \
    && rm frp_* -rf

VOLUME /frp

ENV ARGS=frps

CMD /usr/bin/${ARGS} -c /frp/${ARGS}.ini
