FROM alpine:3.3

RUN apk add --update curl bash zip && \
    rm -rf /var/cache/apk/*

VOLUME ["/data"]

WORKDIR /data
