#!/bin/sh

while ! mariadb -h$MYSQL_HOST -u$WP_DATABASE_USER -p$WP_DATABASE_PWD $WP_DATABASE_NAME >/dev/null 2>&1; do
    sleep 3
done



if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --allow-root
    wp config create --dbname="$WP_DATABASE_NAME" --dbuser="$WP_DATABASE_USER" --dbpass="$WP_DATABASE_PWD" --dbhost="$MYSQL_HOST" --dbcharset="utf8mb4" --dbcollate="utf8mb4_general_ci" --allow-root
    wp core install --url="https://$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PWD" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
    wp user create "$WP_USR" "$WP_EMAIL" --role=author --user_pass="$WP_PWD" --allow-root
    wp theme install inspiro --activate --allow-root
    chown -R www-data:www-data /var/www/html
fi

echo "Wordpress started on port 9000"
exec /usr/sbin/php-fpm8.2 -F -R
