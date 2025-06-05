# Use required Alpine penultimate stable version
# https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Metadata
LABEL maintainer="hutzig@student.hive.fi"
LABEL description="MariaDB image with Tini, proper init and security"

# Install mariadb, client, tini, bash for debugging
RUN apk update && \
    apk add --no-cache mariadb mariadb-client tini bash

# Prepare directories and permissions
RUN mkdir -p /run/mysqld /var/lib/mysql /etc/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy custom config file
COPY ./conf/my-mariadb.cnf /etc/my-mariadb.cnf

# Set permissions on config
RUN chmod 644 /etc/my.cnf

# Copy entrypoint script
COPY ./tools/mariadb-script.sh /usr/local/bin/mariadb-script.sh
RUN chmod +x /usr/local/bin/mariadb-script.sh

# Expose MariaDB default port
EXPOSE 3306

# Use Tini and your script
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/mariadb-script.sh"]

