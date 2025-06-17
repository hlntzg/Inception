# Use required Alpine Linux penultimate stable version
# Reference: https://alpinelinux.org/releases/
FROM alpine:3.21.3

# Install dependencies and PHP 8.3 with required extensions
RUN apk update && apk add --no-cache \
    bash curl wget mariadb-client \
    php83 php83-fpm php83-mysqli php83-json php83-mbstring php83-phar \
    php83-tokenizer php83-session php83-openssl php83-curl php83-xml php83-dom && \
	
	# Create user and group for running WordPress
	addgroup -S www-data && adduser -S -G www-data www-data && \

    # Create web root directories with proper permissions and ownership
    mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \

    # Clean up APK cache
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /var/www/html

# Install wp-cli (WordPress CLI tool)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Link PHP binary: create a symbolic link so that running the php command will actually execute php83
RUN ln -s /usr/bin/php83 /usr/bin/php

# Copy custom PHP-FPM configuration
COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy entrypoint script and set executable
COPY ./tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# Expose PHP-FPM port (used by NGINX)
EXPOSE 9000

# Use the custom entrypoint script to initialize the container
ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
