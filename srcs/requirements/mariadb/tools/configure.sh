#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    chown -R mysql:mysql /var/lib/mysql

    mariadb-install-db --basedir=/usr --datadir=/var/lib/mysql --user=mysql

    file=$(mktemp)
    if [ ! -f $file ]; then
        exit 1
    fi

    cat << EOF > $file
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD';
CREATE DATABASE IF NOT EXISTS $WP_DATABASE_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$WP_DATABASE_USER'@'%' IDENTIFIED BY '$WP_DATABASE_PWD';
GRANT ALL PRIVILEGES ON $WP_DATABASE_NAME.* TO '$WP_DATABASE_USER'@'%';
FLUSH PRIVILEGES;
EOF

    /usr/sbin/mariadbd --user=mysql --bootstrap < $file
    cat $file
    rm -f $file
fi

exec /usr/sbin/mariadbd --user=mysql --console
