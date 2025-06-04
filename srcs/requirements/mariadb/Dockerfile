# Define Alpine as a base image for building mariadb as a lightweight container
FROM alpine:3.21.3

# Set image metadata for maintainership and description
LABEL maintainer="hutzig@student.hive.fi"
LABEL description="MariaDB container built from scratch using Alpine"

# Update package index and install MariaDB packages, Bash shell, and Tini init system in a new layer on top of the current image
RUN apk update && apk add --no-cache mariadb mariadb-client bash tini

# Create directories for MariaDB runtime and set correct ownership to mysql user
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Create directory for custom MariaDB configuration files
RUN mkdir -p /etc/mysql

# Copy custom MariaDB configuration file into the container
COPY ./conf/my.cnf /etc/my.cnf

# Copy initialization scripts and SQL seed files to the MariaDB entrypoint directory
# These scripts will be executed on container startup if present
COPY ./conf/ /docker-entrypoint-initdb.d/

# Copy script and set executable permissions
COPY ./tools/mariadb-script.sh /tmp/mariadb-script.sh
RUN chmod 700 /tmp/mariadb-script.sh

# Expose MariaDB default port: service will be listening on port 3306
EXPOSE 3306

# Use Tini as the init system and set the entrypoint to the custom startup script
# Entrypoint to ensure the container always run the custom MariaDB startup script
ENTRYPOINT ["/sbin/tini", "--", "/tmp/mariadb-script.sh"]
