#!/bin/sh

set -e  # 
# Exit immediately if a command exits with a non-zero status

# Load required environment variables and ensure none are missing
echo "Environment variables loaded for MariaDB:"
: "${DB_NAME:?Missing DB_NAME}"
: "${DB_USER:?Missing DB_USER}"
: "${DB_USER_PWD:?Missing DB_USER_PWD}"
: "${DB_ROOT_USER:?Missing DB_ROOT_USER}"
: "${DB_ROOT_PWD:?Missing DB_ROOT_PWD}"

# Check if the MariaDB system database is already initialized
echo "Checking MariaDB initialization..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Run initial database setup in bootstrap mode
echo "Running database setup..."

# Start MariaDB in bootstrap mode to run SQL directly without launching a full server
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

    -- Grant full privileges on the database to dbroot as well
    GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_ROOT_USER}@'%' WITH GRANT OPTION;

    -- Secure the built-in root@localhost
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';

    -- Reload privilege tables again to apply all changes
    FLUSH PRIVILEGES;
EOF

# Start MariaDB in normal foreground mode
echo "Starting MariaDB normally..."
exec mysqld --user=mysql
