#!/bin/bash
  
cd /var/www/html
cp .env.pipeline .env
service mysql restart
service redis-server restart
mailcatcher
mysql -uroot -proot -e 'create database tenantcloud;'
composer install --no-interaction --no-progress --prefer-dist
php artisan migrate --force
php artisan config:cache
vendor/bin/phpunit -c phpunit.xml --testdox tests/Backend
