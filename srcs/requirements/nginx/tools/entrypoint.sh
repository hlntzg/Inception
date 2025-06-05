#!/bin/sh

set -e

# Required environment variables
: "${DOMAIN_NAME:?DOMAIN_NAME not set}"
: "${CERTS_:=/etc/nginx/ssl/nginx.crt}"
: "${CERTS_KEY_:=/etc/nginx/ssl/nginx.key}"

mkdir -p "$(dirname "$CERTS_")"

# Generate self-signed cert if not present
if [ ! -f "$CERTS_" ] || [ ! -f "$CERTS_KEY_" ]; then
    echo "Generating self-signed cert for $DOMAIN_NAME..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out "$CERTS_" \
        -keyout "$CERTS_KEY_" \
        -subj "/C=FI/L=Helsinki/O=Hive/OU=Student/CN=$DOMAIN_NAME"
    chmod 644 "$CERTS_"
    chmod 600 "$CERTS_KEY_"
else
    echo "Certificates already exist. Skipping generation."
fi

# Replace placeholders in config
sed -e "s|\${DOMAIN_NAME}|$DOMAIN_NAME|g" \
    -e "s|\${CERTS_}|$CERTS_|g" \
    -e "s|\${CERTS_KEY_}|$CERTS_KEY_|g" \
    /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

# Start NGINX
echo "Starting NGINX..."
exec nginx -g "daemon off;"
