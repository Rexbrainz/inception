#!/bin/bash
set -e

# Load secrets from Docker secrets files
MYSQL_PASS=$(cat /run/secrets/mysql_password)
WORDPRESS_ROOT_PASS=$(cat /run/secrets/wordpress_root_password)
WORDPRESS_USER_PASS=$(cat /run/secrets/wordpress_user_password)

export WP_CLI_DISABLE_MAIL=true

# Download and setup wp-cli if not already installed
if ! command -v wp > /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

cd /var/www/html

chmod -R 755 /var/www/html

# Fix PHP-FPM socket to use port 9000 instead of socket file
sed -i '36 s|/run/php/php7.4-fpm.sock|9000|' /etc/php/7.4/fpm/pool.d/www.conf

# Wait for MariaDB to be ready
for i in {1..10}; do
    if mariadb -h mariadb -P 3306 \
        -u "${MYSQL_USER}" \
        -p"${MYSQL_PASS}" -e "SELECT 1" &>/dev/null; then
        break
    else
        echo "Waiting for MariaDB to be ready... (${i}/10)"
        sleep 2
    fi
done

# Download WordPress core if not present
if [ ! -f index.php ]; then
    wp core download --allow-root
fi

# Create wp-config.php if not present
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASS}" \
        --dbhost="mariadb:3306" --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ROOT_NAME}" \
        --admin_password="${WORDPRESS_ROOT_PASS}" \
        --admin_email="${WORDPRESS_ROOT_EMAIL}" --allow-root 2> >(grep -v '/usr/sbin/sendmail: not found' >&2)
fi

# Handle theme activation/install
if wp theme is-active twentytwentyfour --allow-root; then
    echo "Theme 'twentytwentyfour' already active."
elif wp theme is-installed twentytwentyfour --allow-root; then
    wp theme activate twentytwentyfour --allow-root
else
    wp theme install twentytwentyfour --activate --allow-root
fi

# Create a normal user if not exists
if ! wp user get "${WORDPRESS_USERNAME}" --allow-root &>/dev/null; then
    wp user create "${WORDPRESS_USERNAME}" "${WORDPRESS_USER_EMAIL}" \
        --user_pass="${WORDPRESS_USER_PASS}" \
        --role="${WORDPRESS_USER_ROLE}" --allow-root
fi

# Fix permissions for www-data
chown -R www-data:www-data /var/www/html

mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F

