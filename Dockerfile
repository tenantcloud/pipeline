FROM php:7.1

MAINTAINER Igor Bronovskyi <admin@brun.if.ua>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -qy wget locales apt-utils lsb-release apt-transport-https ruby python python3 perl ca-certificates git imagemagick openssh-client zip zlib1g-dev libicu-dev libpng-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl gd zip pdo pdo_mysql
RUN wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb && dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb && rm percona-release_0.1-4.$(lsb_release -sc)_all.deb
RUN apt-get update
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt-get install -y percona-server-server-5.7
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get autoclean && apt-get clean && apt-get autoremove

RUN \
 curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin &&\
 curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept &&\
 chmod a+x /usr/local/bin/codecept &&\
 npm install --no-color --production --global gulp-cli webpack mocha grunt &&\
 rm -rf /root/.npm /root/.composer /tmp/* /var/lib/apt/lists/* &&\
 composer global require "fxp/composer-asset-plugin:^1.2.0"
