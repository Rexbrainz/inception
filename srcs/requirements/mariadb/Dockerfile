FROM        debian:bullseye

WORKDIR     /etc/mariadb

RUN         apt-get update && \
            apt-get install -y mariadb-server mariadb-client openssl && \
            rm -rf /var/lib/apt/lists/*

COPY        ./tools/mariadb.sh /etc/mariadb

RUN         chmod +x /etc/mariadb/mariadb.sh

ENTRYPOINT  [ "./mariadb.sh" ]
