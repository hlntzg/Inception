#!/bin/sh
set -e

: "${WP_TITLE:?Missing WP_TITLE}"
: "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
: "${WP_ADMIN_PWD:?Missing WP_ADMIN_PWD}"
: "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL}"
: "${WP_DB_NAME:?Missing WP_DB_NAME}"
: "${WP_DB_USER:?Missing WP_DB_USER}"
: "${WP_DB_PWD:?Missing WP_DB_PWD}"
: "${WP_DB_HOST:?Missing WP_DB_HOST}"
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"

# Wait for DB to be ready (ping)
until mysql -h"${WP_DB_HOST}" -u"${WP_DB_USER}" -p"${WP_DB_PWD}" -e "SELECT 1;" > /dev/null 2>&1; do
  echo "Waiting for MariaDB..."
  sleep 1
done

# Download WP core if not already
if [ ! -f wp-config.php ]; then
  wp core download --allow-root

  wp config create --dbname="${WP_DB_NAME}" \
                   --dbuser="${WP_DB_USER}" \
                   --dbpass="${WP_DB_PWD}" \
                   --dbhost="${WP_DB_HOST}" \
                   --path=/var/www/html --allow-root

  wp core install --url="${DOMAIN_NAME}" \
                  --title="${WP_TITLE}" \
                  --admin_user="${WP_ADMIN_USER}" \
                  --admin_password="${WP_ADMIN_PWD}" \
                  --admin_email="${WP_ADMIN_EMAIL}" \
                  --skip-email --allow-root
fi

# Start php-fpm (must not daemonize)
exec php-fpm81 --nodaemonize
