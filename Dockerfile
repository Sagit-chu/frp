FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG

WORKDIR /root
RUN apk add --update git \
    && git clone https://github.com/fatedier/frp frp \
    && cd ./frp \
    && git fetch --all --tags \
    && git checkout tags/${TAG} \
    && go build -ldflags "-s -w" -trimpath -o frps \
    && go build -ldflags "-s -w" -trimpath -o frpc

FROM --platform=${TARGETPLATFORM} alpine:latest

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
# ARG URL=https://github.com/fatedier/frp/releases/download/v${VER}/frp_${VER}_linux_${TARGETPLATFORM}.tar.gz

COPY --from=builder /root/frp/frp* /frp
RUN mkdir -p /frp \
    && cd /frp\
    && mv frp_*/frpc /usr/bin/ \
    && mv frp_*/frps /usr/bin/ \
    && mv frp_*/*.ini ./ \
    && rm frp_* -rf

VOLUME /frp

ENV ARGS=frps

CMD /usr/bin/${ARGS} -c /frp/${ARGS}.ini
