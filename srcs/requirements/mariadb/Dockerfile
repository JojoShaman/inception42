FROM debian:bookworm

LABEL "author"="srosu"

RUN apt update -y && apt upgrade -y && apt install mariadb-server -y
RUN rm -rf /var/lib/mysql/*
RUN sed -i "s|.*bind-address\s*=.*|bind-address = 0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/configure.sh /tmp/configure.sh

ENTRYPOINT [ "sh", "/tmp/configure.sh" ]
