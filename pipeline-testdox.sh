#!/bin/bash
  
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld # fix mysql for mac os
cd /var/www/html
cp .env.pipeline .env
service mysql restart
service redis-server restart
service minio restart
mailcatcher
mysql -uroot -proot -e 'create database tenantcloud;'
minio-client config host add s3 http://127.0.0.1:9000 pipeline pipeline
minio-client mb pipeline
composer install --no-interaction --no-progress --prefer-dist
php artisan migrate --force
php artisan config:cache
vendor/bin/phpunit -c phpunit.xml --testdox tests/Backend
