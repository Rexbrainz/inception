FROM        debian:bullseye

WORKDIR     /etc/nginx

RUN         apt-get update -y && \
            apt-get install -y nginx openssl sudo curl && \
            rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/*

COPY        ./conf/nginx.sh ./nginx.sh

RUN         chmod +x ./nginx.sh

EXPOSE      443

ENTRYPOINT  [ "./nginx.sh" ]

