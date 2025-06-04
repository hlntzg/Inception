#!/bin/sh
set -e

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "[+] Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "[+] Starting MariaDB for setup..."
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    i=30
    while [ $i -gt 0 ]; do
        if mariadb --socket=/run/mysqld/mysqld.sock -u root &>/dev/null; then
            break
        fi
        echo "Waiting up to 30s for MariaDB to start..."
        sleep 1
        i=$((i - 1))
    done

    if [ "$i" = 0 ]; then
        echo "MariaDB init process failed."
        exit 1
    fi

    echo "[+] Running setup SQL..."
    mariadb --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    kill "$pid"
    wait "$pid"
fi

echo "[+] Starting MariaDB normally..."
exec mariadbd --user=mysql
