#!/bin/sh

set -e # Fast fail: Exit if any command fails

echo "Environment variables loaded for WordPress:"
env | grep -E '^(WP_|DB_|DOMAIN_NAME)'

# WordPress admin and site config
: "${WP_TITLE:?Missing WP_TITLE}"
: "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
: "${WP_ADMIN_PWD:?Missing WP_ADMIN_PWD}"
: "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL}"
# Optional extra WordPress user (subscriber)
: "${WP_USER:?Missing WP_USER}"
: "${WP_USER_EMAIL:?Missing WP_USER_EMAIL}"
: "${WP_USER_PWD:?Missing WP_USER_PWD}"
# Database config
: "${DB_NAME:?Missing DB_NAME}"
: "${DB_USER:?Missing DB_USER}"
: "${DB_USER_PWD:?Missing DB_USER_PWD}"
: "${DB_HOST:?Missing DB_HOST}"
# Domain
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"

# Change to the WordPress document root
cd /var/www/html

# Ensure idempotent WP startup
MARKER=".initialized"

if [ ! -e "${MARKER}" ]; then
  echo "First time setup in progress..."

  echo "Waiting for MariaDB to be ready using mariadb-admin ping (blocking)..."
  # This blocks until the server is ready or fails
  mariadb-admin ping \
    --protocol=tcp \
    --host="$DB_HOST" \
    --user="$DB_USER" \
    --password="$DB_USER_PWD" \
    --wait \
    >/dev/null 2>&1

  echo "MariaDB is up."

  if [ ! -f wp-config.php ]; then
    # This downloads the WordPress core files, the option ( --allow-root ) will run the command as root
    # and ( --local=en_US ) sets the language of the installation to US English
    echo "Downloading WordPress core..."
    ./wp-cli.phar core download --allow-root --locale=en_US || true

    # This will generate the WordPress configuration file, and the options ( --dbname, --dbuser, --dbpass, --dbhost )
    # are just placeholders that will get replaced once the script runs
    echo "Creating wp-config.php..."
    ./wp-cli.phar config create \
      --allow-root \
      --dbname="${DB_NAME}" \
      --dbuser="${DB_USER}" \
      --dbpass="${DB_USER_PWD}" \
      --dbhost="${DB_HOST}"

    # This will then install WordPress, and again, all the options are just placeholders that will get replaced
    echo "Installing WordPress..."
    ./wp-cli.phar core install \
      --allow-root \
      --url="${DOMAIN_NAME}" \
      --title="${WP_TITLE}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PWD}" \
      --admin_email="${WP_ADMIN_EMAIL}" \
      --skip-email
      
    # This create a new WordPress user, and sets its role to subscriber (--role=subscriber)
    if [ -n "$WP_USER" ] && [ -n "$WP_USER_EMAIL" ] && [ -n "$WP_USER_PWD" ]; then
      echo "Creating additional user: $WP_USER"
      ./wp-cli.phar user create "$WP_USER" "$WP_USER_EMAIL" \
        --allow-root \
        --user_pass="$WP_USER_PWD" \
        --role=subscriber
    fi
    
  else
    echo "wp-config.php already exists. Skipping core install."
  fi


  echo "Setting permissions..."
  chown -R www-data:www-data /var/www/html

  touch "${MARKER}"
  echo "Initialization complete."
else
  echo "Existing installation detected. Skipping setup."
fi

# Start PHP-FPM (must not daemonize). This is the command that will keep WordPress up and running
echo "Starting PHP-FPM..."
exec php-fpm83 --nodaemonize
