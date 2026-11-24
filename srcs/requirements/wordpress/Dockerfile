FROM debian:bookworm

LABEL "author"="srosu"

RUN apt update -y && apt upgrade -y && apt install -y \
    mariadb-client \
    php-fpm \
    php-cli \
    php-curl \
    php-mysql \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    php-intl \
    wget

RUN sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = 9000|" /etc/php/8.2/fpm/pool.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN cp wp-cli.phar /usr/bin/wp

RUN mkdir -p /run/php

WORKDIR /var/www/html

COPY tools/configure.sh /tmp/configure.sh

ENTRYPOINT [ "sh", "/tmp/configure.sh" ]
