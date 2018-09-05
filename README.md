# Pipeline image for Laravel 5.5+

[Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) [Docker](https://www.docker.com/) image based on [Ubuntu 16.04](https://ubuntu.com/) with [PHP 7.1 {latest}](http://php.net/)/[MySQL 5.7](https://www.mysql.com)/[Minio.io](https://minio.io)

More help in Bitbucket's [Confluence](https://confluence.atlassian.com/bitbucket/bitbucket-pipelines-beta-792496469.html)

Docker image at [tenantcloud/pipline](https://hub.docker.com/r/tenantcloud/pipeline/) (no `CMD` as it is overriden by *Pipelines*)

## Packages installed

 - `php7.1`, `mysql-server 5.7`, `mysql-client`, `git`, `composer`, `minio`  etc
 - Latest [Composer](https://getcomposer.org/), [Gulp](http://gulpjs.com/), [Webpack](https://webpack.github.io/), [Mocha](https://mochajs.org/), [Grunt](http://gruntjs.com/), [Codeception](http://codeception.com/), work with [KarmaJS](https://karma-runner.github.io/2.0/index.html)

## Environments

Default MySQL user: `root`, password: `root`

## Sample `bitbucket-pipelines.yml`

```YAML
image: tenantcloud/pipeline

pipelines:
  custom:
    all:
      - step:
          deployment: test
          name: Runs php-unit && php-integration
          script:
            - cp .env.pipeline .env
            - service mysql restart
            - service redis-server restart
            - service minio restart
            - mailcatcher
            - sleep 10 && mysql -uroot -proot -e 'create database tenantcloud;'
            - composer install --no-interaction --no-progress --prefer-dist
            - php artisan migrate --force
            - php artisan route:cache
            - vendor/bin/phpunit -c phpunit-pipeline.xml tests/Backend
            - npm install --ignore-scripts
            - gulp
            - ln -s $(pwd)/node_modules $(pwd)/public/
            - npm run test
```

## Use localy

```bash
cd /home/user/code
git archive --remote=ssh://git@bitbucket.org/brun/site.git --format=zip --output="site.zip" release
unzip site.zip -d site
rm site.zip
docker run --rm -it -v /home/user/code/site:/var/www/html tenantcloud/pipeline /pipeline.sh
## or run unit test and stop on failure
# docker run --rm -it -v /home/user/code/site:/var/www/html tenantcloud/pipeline /pipeline-on-failure.sh
```

More information on this likn [https://ukietech.atlassian.net/wiki/x/awFNLg](https://ukietech.atlassian.net/wiki/x/awFNLg)
