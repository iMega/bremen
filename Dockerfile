FROM alpine:3.4

EXPOSE 80

RUN apk add --no-cache nginx-lua rsync && \
    mkdir -p /tmp/nginx/client-body /app/logs /run/nginx

COPY . /

VOLUME ["/data"]

CMD ["/usr/sbin/nginx", "-g", "daemon off;", "-p", "/app", "-c", "/nginx.conf"]
