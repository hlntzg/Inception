# Use required Alpine penultimate stable version
# Reference: https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Install mariadb, client bash (for scripting support)
RUN apk update && apk add --no-cache \
	mariadb mariadb-client bash

# Copy custom config file
COPY ./conf/mariadb.cnf /etc/my.cnf

# Set permissions on config
RUN chmod 644 /etc/my.cnf

# Prepare directories and permissions
RUN mkdir -p /run/mysqld /var/lib/mysql /etc/mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

# Copy entrypoint script for initialization
COPY ./tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# Expose MariaDB default port
EXPOSE 3306

# Use the custom entrypoint script to initialize the container
ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
