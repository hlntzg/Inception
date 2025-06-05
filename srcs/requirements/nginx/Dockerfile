# Use required Alpine penultimate stable version
# https://alpinelinux.org/releases/
FROM alpine:3.21.3

RUN apk update && apk add --no-cache nginx openssl tini bash

# Create needed directories
RUN mkdir -p /run/nginx /etc/nginx/ssl /var/log/nginx

# Copy configs
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf.template /etc/nginx/http.d/default.conf.template

COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
