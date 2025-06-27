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



# Use required Alpine penultimate stable version
# Reference: https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Update package index and install required packages:
# - nginx: web server
# - gettext: for envsubst (used in templating configs)
# - openssl: for SSL certificates
# - bash: for scripting support
RUN apk update && apk add --no-cache \
	nginx gettext openssl bash && \
	mkdir -p /etc/nginx/ssl

# Copy Nginx configuration file into the default site config location
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

# Copy custom entrypoint script and make it executable
COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Expose HTTPS port (443)
EXPOSE 443

# Set the container entrypoint to the custom script
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
