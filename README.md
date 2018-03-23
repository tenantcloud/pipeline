# Pipeline image for Laravel 5.5+

[Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) [Docker](https://www.docker.com/) image based on [Debian/Jessie](https://www.debian.org/releases/jessie/) with [PHP 7.1 {latest}](http://php.net/)/[MySQL](https://www.mysql.com)

More help in Bitbucket's [Confluence](https://confluence.atlassian.com/bitbucket/bitbucket-pipelines-beta-792496469.html)

Docker image at [tenantcloud/pipline](https://hub.docker.com/r/tenantcloud/pipeline/) (no `CMD` as it is overriden by *Pipelines*)

## Packages installed

 - `php7.1`, `mysql-server 5.7`, `mysql-client`, `git`, `composer`,  etc
 - Latest [Composer](https://getcomposer.org/), [Gulp](http://gulpjs.com/), [Webpack](https://webpack.github.io/), [Mocha](https://mochajs.org/), [Grunt](http://gruntjs.com/), [Codeception](http://codeception.com/)

## Environments

Default MySQL user: `root`, password: `root`

## Sample `bitbucket-pipelines.yml`

```YAML
image: tenantcloud/pipline
pipelines:
  default:
    - step:
        script:
          - service mysql start
          - mysql -h localhost -u root -proot -e "CREATE DATABASE test;"
          - cp .env.example .env
          - composer install --no-interaction --no-progress --prefer-dist
          - npm install --no-spin
          - php artisan migrate --force
          - vendor/bin/phpunit tests/Backend
```
