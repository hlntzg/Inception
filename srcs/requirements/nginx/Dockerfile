FROM alpine:3.21.3

RUN apk update && apk add --no-cache nginx openssl bash tini

# Required directories for socket and certificates
RUN mkdir -p /run/nginx /etc/nginx/ssl

# Self-signed SSL certificate
# out: path ; keyout: ; subj: ;
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out /etc/nginx/ssl/nginx_public_certificate.crt \
  -keyout /etc/nginx/ssl/nginx.key \
  -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42Inception/CN=hutzig.42.fr"

# Lock down permissions on the private key
RUN chmod 600 /etc/nginx/ssl/nginx.key

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["nginx", "-g", "daemon off;"]
