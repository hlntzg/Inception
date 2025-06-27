#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status

echo "Environment variables loaded for WordPress:"
env | grep -E '^(DOMAIN_NAME)'

# Domain
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"

# Generate a self-signed SSL certificate valid for 365 days
# - Creates a 2048-bit RSA key
# - No passphrase on the private key (-nodes)
# - Outputs key and cert to /etc/nginx/ssl/
# - Sets the subject's common name (CN) to the domain name
openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
    -keyout /etc/nginx/ssl/cert.key \
    -out /etc/nginx/ssl/cert.crt \
    -subj "/CN=$DOMAIN_NAME"

# Set strict permissions on the private key (read/write for owner only)
chmod 600 /etc/nginx/ssl/cert.key

# Set standard permissions on the certificate (readable by others)
chmod 644 /etc/nginx/ssl/cert.crt

# Start NGINX in the foreground (keep container running)
exec nginx -g "daemon off;"
