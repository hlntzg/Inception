#!/bin/sh
set -e

echo "[+] Checking MariaDB initialization..."

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "[+] Starting MariaDB temporarily for setup..."
mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
pid="$!"

# Wait for socket to be available (max 30s)
timeout=30
while ! mariadb --socket=/run/mysqld/mysqld.sock -u root &>/dev/null; do
    echo "Waiting for MariaDB to start..."
    sleep 1
    timeout=$((timeout - 1))
    if [ "$timeout" -le 0 ]; then
        echo "MariaDB failed to start within timeout."
        kill "$pid"
        exit 1
    fi
done

echo "[+] Running database setup..."

mariadb --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PWD}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
    FLUSH PRIVILEGES;
EOSQL

kill "$pid"
wait "$pid"

echo "[+] Starting MariaDB normally..."
exec mysqld --user=mysql
