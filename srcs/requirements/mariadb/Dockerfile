# Use required Alpine penultimate stable version
# https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Install mariadb, client bash
RUN apk update && \
    apk add --no-cache mariadb mariadb-client bash

# Copy custom config file
COPY ./conf/mariadb.cnf /etc/mariadb.cnf

# Set permissions on config
RUN chmod 644 /etc/my.cnf

# Prepare directories and permissions
RUN mkdir -p /run/mysqld /var/lib/mysql /etc/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy entrypoint script
COPY ./tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# Expose MariaDB default port
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
