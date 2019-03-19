#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld # fix mysql for mac os
cd /var/www/html
cp .env.pipeline .env
service mysql restart
service redis-server restart
service minio restart
mailcatcher
sleep 5
mysql -uroot -proot -e 'create database tenantcloud;'
minio-client config host add s3 http://127.0.0.1:9000 pipeline pipeline
sleep 5 && minio-client mb s3/pipeline

HTTP_DIR=/var/www/html
composer install --no-interaction --no-progress --prefer-dist
composer dump-autoload -o
php artisan migrate --force
php artisan db:seed
php artisan config:cache
php artisan route:cache

# Main DB name
DB_NAME="tenantcloud"
# File for dump main DB
DUMP_FILE="/tmp/tenantcloud_dump.sql.gz"

echo "Create  dump from DB $DB_NAME"
mysqldump --single-transaction --routines --events --extended-insert -uroot -proot \
  $DB_NAME | gzip > $DUMP_FILE

# Number of processes (CPU cores * 2)
PROCESSES=8
# Create new DBs (skip 1 because already created) and copy data from main DB
for i in $(seq 2 $PROCESSES); do
  # New DB name
  DB_NAME_NEW="${DB_NAME}_${i}"

  echo "Create DB $DB_NAME_NEW and import data"
  mysql -uroot -proot -e "create database $DB_NAME_NEW" 2>/dev/null
  gunzip < $DUMP_FILE | mysql -uroot -proot $DB_NAME_NEW 2>/dev/null
done

  # # Install 
  # # apt-get install mysql-utilities
  # for i in $(seq 2 $PROCESSES); do
  #     DB_NAME_NEW="tenantcloud_${i}"
  #     echo "Clone DB: ${DB_NAME_NEW}"
  #     # rsync -aup /var/lib/mysql/tenantcloud/* /var/lib/mysql/${DB_NAME_NEW}
  #     # Visit: https://gist.github.com/kolunar/f07aa6ac2752640db1efe0f619889220
  #     mysqldbcopy --source=root@localhost:3306 --destination=root@localhost:3306 tenantcloud:${DB_NAME_NEW}
  # done
  # chown mysql:mysql /var/lib/mysql/*
  # service mysql start

vendor/bin/paratest -p"$PROCESSES" -c phpunit.xml tests/Backend 2>&1

echo "Start FrontEnd tests"
npm i
npm run testing
npm run test

