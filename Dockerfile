FROM php:7.1.1

MAINTAINER Igor Bronovskyi <admin@brun.if.ua>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

RUN \
 apt-get update &&\
 echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
 locale-gen en_US.UTF-8 &&\
 /usr/sbin/update-locale LANG=en_US.UTF-8 &&\
 apt-get -y --no-install-recommends install wget locales apt-utils lsb-release apt-transport-https ruby python python3 \
 perl ca-certificates git imagemagick openssh-client zip zlib1g-dev libicu-dev libpng-dev g++ &&\
 docker-php-ext-configure intl &&\
 docker-php-ext-install intl gd zip pdo pdo_mysql &&\
 wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb -O mysql.deb && dpkg -i mysql.deb && rm mysql.deb &&\
 apt-get update &&\
 echo "mysql-server mysql-server/root_password password root" | debconf-set-selections &&\
 echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections &&\
 apt-get -y --no-install-recommends install mysql-community-server mysql-client &&\
 curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
 apt-get -y --no-install-recommends install nodejs &&\
 apt-get autoclean && apt-get clean && apt-get autoremove

RUN \
 curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin &&\
 curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept &&\
 chmod a+x /usr/local/bin/codecept &&\
 npm install --no-color --production --global gulp-cli webpack mocha grunt &&\
 rm -rf /root/.npm /root/.composer /tmp/* /var/lib/apt/lists/* &&\
 composer global require "fxp/composer-asset-plugin:^1.2.0"