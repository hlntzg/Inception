# Use required Alpine penultimate stable version
# https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Install PHP and extensions for WordPress
RUN apk update && apk add --no-cache \
    php81 php81-fpm php81-mysqli php81-mbstring php81-phar php81-tokenizer php81-json php81-session \
    mariadb-client \
    curl wget bash \
    && rm -rf /var/cache/apk/*

# WP-CLI install
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on all interfaces (not just localhost)
COPY ./conf/www.conf /etc/php81/php-fpm.d/www.conf

# Create working directories
RUN mkdir -p /var/www/html /run/php && \
    chown -R nobody:nogroup /var/www/html

# Optional: link php binary for easier command usage
RUN ln -s /usr/bin/php81 /usr/bin/php

# Copy entrypoint
COPY ./tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

USER default_user

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
