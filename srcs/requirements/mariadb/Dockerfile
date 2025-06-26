# Use required Alpine penultimate stable version
# Reference: https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Install MariaDB, MariaDB client, and bash (for scripting support)
RUN apk update && apk add --no-cache \
	mariadb mariadb-client bash

# Copy custom MariaDB configuration
COPY ./conf/mariadb.cnf /etc/my.cnf

# Set permissions on config
RUN chmod 644 /etc/my.cnf

# Prepare necessary directories and permissions
# Initialize the MariaDB data directory
RUN mkdir -p \
      /run/mysqld \
      /var/lib/mysql \
      /etc/mysql \
      /var/log/mysql && \
    chown -R mysql:mysql \
      /run/mysqld \
      /var/lib/mysql \
      /var/log/mysql && \
    mariadb-install-db \
      --user=mysql \
      --datadir=/var/lib/mysql

# Copy custom entrypoint script and make it executable
COPY ./tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh 

# Expose MariaDB default port
EXPOSE 3306

# Define the entrypoint for container startup
ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
