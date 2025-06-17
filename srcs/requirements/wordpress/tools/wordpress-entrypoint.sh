#!/bin/sh

# Fast fail: Exit if any command fails
set -e

# For debugging:
echo "Environment variables loaded for WordPress:"
env | grep -E '^(WP_|DB_|DOMAIN_NAME)'

# Strict env variable checks
: "${WP_TITLE:?Missing WP_TITLE}"
: "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
: "${WP_ADMIN_PWD:?Missing WP_ADMIN_PWD}"
: "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL}"
: "${WP_DB_NAME:?Missing WP_DB_NAME}"
: "${WP_DB_USER:?Missing WP_DB_USER}"
: "${WP_DB_PWD:?Missing WP_DB_PWD}"
: "${WP_DB_HOST:?Missing WP_DB_HOST}"
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"

# Optional extra user vars (commented for now, not sure if needed)
# WP_USER=${WP_USER:-}
# WP_USER_EMAIL=${WP_USER_EMAIL:-}
# WP_USER_PASSWORD=${WP_USER_PASSWORD:-}

# Wait for DB to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h"${WP_DB_HOST}" -u"${WP_DB_USER}" -p"${WP_DB_PWD}" -e "SELECT 1;" > /dev/null 2>&1; do
  echo "Still waiting for MariaDB..."
  sleep 1
done
echo "MariaDB is up."

# Ensure idempotent WP startup
MARKER=".initialized"

if [ ! -f "${MARKER}" ]; then
  echo "First time setup in progress..."

  if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
      --dbname="${WP_DB_NAME}" \
      --dbuser="${WP_DB_USER}" \
      --dbpass="${WP_DB_PWD}" \
      --dbhost="${WP_DB_HOST}" \
      --allow-root

    echo "Installing WordPress..."
    wp core install \
      --url="${DOMAIN_NAME}" \
      --title="${WP_TITLE}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PWD}" \
      --admin_email="${WP_ADMIN_EMAIL}" \
      --skip-email \
      --allow-root
  else
    echo "wp-config.php already exists. Skipping core install."
  fi

  # Create additional user if defined (optional block)
  # if [ -n "$WP_USER" ] && [ -n "$WP_USER_EMAIL" ] && [ -n "$WP_USER_PASSWORD" ]; then
  #   echo "Creating additional user: $WP_USER"
  #   wp user create "$WP_USER" "$WP_USER_EMAIL" \
  #     --user_pass="$WP_USER_PASSWORD" \
  #     --allow-root
  # fi

  echo "Setting permissions..."
  chown -R www-data:www-data /var/www/html

  touch "${MARKER}"
  echo "Initialization complete."
else
  echo "Existing installation detected. Skipping setup."
fi

# Start PHP-FPM (must not daemonize)
echo "Starting PHP-FPM..."
exec php-fpm83 --nodaemonize
