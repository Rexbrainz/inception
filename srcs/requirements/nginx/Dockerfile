FROM        debian:bullseye

WORKDIR     /etc/nginx

RUN         apt-get update -y && apt-get upgrade -y && \
            apt-get install -y nginx openssl sudo curl && \
            rm -rf /var/lib/apt/lists/*

COPY        ./conf/nginx.sh ./nginx.sh

RUN         chmod +x ./nginx.sh

ENTRYPOINT  [ "./nginx.sh" ]

