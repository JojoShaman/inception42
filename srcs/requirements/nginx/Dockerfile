FROM debian:bookworm

LABEL "author"="srosu"

RUN apt update -y && apt upgrade -y && apt install nginx openssl -y

RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -keyout /etc/nginx/ssl/srosu.key \
    -out /etc/nginx/ssl/srosu.pem \
    -subj "/C=BE/ST=Brussels/L=Brussels/O=42 Belgium/OU=srosu/CN=srosu.42.fr/"

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
