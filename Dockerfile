FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG=v0.43.0

WORKDIR /root
RUN apk add --update git \
    && git clone https://github.com/fatedier/frp frp \
    && cd ./frp \
    && git fetch --all --tags \
    && git checkout tags/${TAG} \
    && go build -ldflags "-s -w" -trimpath -o /root/frp/frps ./cmd/frps\
    && go build -ldflags "-s -w" -trimpath -o /root/frp/frpc ./cmd/frpc

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

RUN mkdir -p /frp
COPY --from=builder /root/frp/frp* /frp/
RUN cd /frp \
    && mv frpc /usr/bin/ \
    && mv frps /usr/bin/ \
    && rm frp -rf
ADD https://raw.githubusercontent.com/fatedier/frp/dev/conf/frpc_full.ini /frp/frpc.ini
ADD https://raw.githubusercontent.com/fatedier/frp/dev/conf/frps_full.ini /frp/frps.ini


VOLUME /frp

ENV ARGS=frps

CMD /usr/bin/${ARGS} -c /frp/${ARGS}.ini
