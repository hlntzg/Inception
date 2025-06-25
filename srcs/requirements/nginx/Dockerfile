# # Base image required Alpine penultimate stable version
# # https://alpinelinux.org/releases/
# FROM alpine:3.21.3

# RUN apk update && \
#     apk add nginx openssl bash sed

# # Copy entrypoint script
# COPY ./tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh

# # Copy NGINX config template
# COPY ./conf/default.conf.template /etc/nginx/http.d/default.conf.template

# RUN mkdir -p /etc/nginx/ssl && \
# 	mkdir -p /run/nginx /var/log/nginx && \
# 	chmod +x /usr/local/bin/nginx-entrypoint.sh

# # Expose HTTPS port
# EXPOSE 443

# ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]

# Base image required Alpine penultimate stable version
# https://alpinelinux.org/releases/
FROM alpine:3.21.3

RUN apk update && \
	apk add --no-cache nginx gettext openssl bash && \
	mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/nginx-entrypoint.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Expose HTTPS port
EXPOSE 443

# Set the container entrypoint to the custom script
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
