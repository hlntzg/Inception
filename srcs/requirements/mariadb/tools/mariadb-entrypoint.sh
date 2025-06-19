#!/bin/sh
set -e

: "${DB_NAME:?Missing DB_NAME}"
: "${DB_USER:?Missing DB_USER}"
: "${DB_USER_PWD:?Missing DB_USER_PWD}"
: "${DB_ROOT_USER:?Missing DB_ROOT_USER}"
: "${DB_ROOT_PWD:?Missing DB_ROOT_PWD}"

echo "[+] Checking MariaDB initialization..."

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

#echo "[+] Starting MariaDB temporarily for setup..."
#mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
#pid="$!"

# Wait for socket to be available (max 30s)
#timeout=30
#while ! mariadb --socket=/run/mysqld/mysqld.sock -u root &>/dev/null; do
#    echo "Waiting for MariaDB to start..."
#    sleep 1
#    timeout=$((timeout - 1))
#    if [ "$timeout" -le 0 ]; then
#        echo "MariaDB failed to start within timeout."
#        kill "$pid" 
#        exit 1
#    fi
#done

echo "[+] Running database setup..."

# Start MariaDB in bootstrap mode to run initialization SQL commands without starting the full server
mysqld --user=mysql --bootstrap <<EOF
    -- Select the system database
    USE mysql;

    -- Reload privilege tables to ensure they are up to date
    FLUSH PRIVILEGES;

    -- Create the WordPress database if it doesn't already exist
    CREATE DATABASE IF NOT EXISTS ${DB_NAME};

    -- Create the WordPress database user (if not exists) and set the password
    CREATE USER IF NOT EXISTS ${DB_USER}@'%' IDENTIFIED BY '${DB_USER_PWD}';

    -- Grant all privileges on the WordPress database to the user, with the ability to grant further privileges
    GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@'%' WITH GRANT OPTION;

    -- Create the root user for remote access (if not exists) and set the password
    CREATE USER IF NOT EXISTS ${DB_ROOT_USER}@'%' IDENTIFIED BY '${DB_ROOT_PWD}';

    -- Ensure the root user password is set even if the user already exists
    ALTER USER ${DB_ROOT_USER}@'%' IDENTIFIED BY '${DB_ROOT_PWD}';

    -- Secure the built-in root@localhost
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';

    -- Reload privilege tables again to apply all changes
    FLUSH PRIVILEGES;
EOF

#mariadb --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
#    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
#    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PWD}';
#    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
#    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
#    FLUSH PRIVILEGES;
#EOSQL

#kill "$pid"
#wait "$pid"

echo "[+] Starting MariaDB normally..."
exec mysqld --user=mysql
