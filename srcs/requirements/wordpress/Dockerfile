FROM        debian:bullseye

RUN         apt-get update -y && apt-get upgrade -y && \
            apt-get install -y curl php php-mysql php7.4-fpm mariadb-client && \
            rm -rf /var/lib/apt/lists/*

COPY        ./tools/wordpress.sh /wordpress.sh

RUN         chmod +x /wordpress.sh

ENTRYPOINT  [ "/wordpress.sh" ]
