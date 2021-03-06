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
composer install --no-interaction --no-progress --prefer-dist
php artisan migrate --force
php artisan db:seed
php artisan config:cache
php artisan route:cache
vendor/bin/phpunit -c phpunit.xml --testdox tests/Backend
