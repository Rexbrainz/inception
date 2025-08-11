#!/bin/bash
set -e

MYSQL_PASS=$(cat /run/secrets/mysql_password)

# Patch bind-address to allow remote connections
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB server in the background
mysqld_safe &

# Wait until MariaDB is ready
until mysqladmin ping --silent; do
  sleep 1
done

# Create database and user
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Shutdown the server cleanly before exec
mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -u root

# Start the server in foreground (container main process)
exec mysqld

