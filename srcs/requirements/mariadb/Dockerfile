# ---------------- BASE ----------------
FROM alpine:3.21.3

# ---------------- METADATA ----------------
LABEL maintainer="hutzig@student.hive.fi"
LABEL description="MariaDB container built from scratch using Alpine"

# ---------------- INSTALL ----------------
RUN apk update && apk add --no-cache mariadb mariadb-client bash tini

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Optional custom config
RUN mkdir -p /etc/mysql
COPY ./conf/my.cnf /etc/my.cnf

# Copy optional seed script
COPY ./conf/ /docker-entrypoint-initdb.d/

COPY ./tools/mariadb-script.sh /tmp/mariadb-script.sh
RUN chmod 700 /tmp/mariadb-script.sh

# ---------------- PORT ----------------
EXPOSE 3306

# ---------------- ENTRYPOINT ----------------
ENTRYPOINT ["/sbin/tini", "--", "/tmp/mariadb-script.sh"]
