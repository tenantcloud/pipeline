FROM php:7.1

MAINTAINER Igor Bronovskyi <admin@brun.if.ua>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y --no-install-recommends wget install locales apt-utils lsb-release apt-transport-https ruby python python3 perl ca-certificates git imagemagick openssh-client zip zlib1g-dev libicu-dev libpng-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl gd zip pdo pdo_mysql
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb -O mysql.deb && dpkg -i mysql.deb && rm mysql.deb
RUN apt-get update
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt-get -y --no-install-recommends install mysql-community-server mysql-client
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y --no-install-recommends install nodejs
RUN apt-get autoclean && apt-get clean && apt-get autoremove

RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin
RUN curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept
RUN chmod a+x /usr/local/bin/codecept
RUN npm install --no-color --production --global gulp-cli webpack mocha grunt
RUN rm -rf /root/.npm /root/.composer /tmp/* /var/lib/apt/lists/*
RUN composer global require "fxp/composer-asset-plugin:^1.2.0"