# See https://github.com/docker-library/php/blob/master/7.1/fpm/Dockerfile
FROM php:5.6-cli-jessie
ARG TIMEZONE

# Based on the work of MAINTAINER Maxence POUTORD <maxence.poutord@gmail.com>
MAINTAINER Danny Bollaert <Danny.Bollaert@gmail.com>

RUN apt-get install curl -y

RUN apt-get update && apt-get install --force-yes -y \
    openssl \
    git \
    unzip \
    openjdk-7-jdk \
    ant \
    devscripts \
    build-essential \
    lintian \
    ruby \
    ruby-dev \
    rubygems \
    gcc \ 
    make

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version
# Install fpm
RUN gem install --no-ri --no-rdoc fpm

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Type docker-php-ext-install to see available extensions


# install xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


RUN echo 'alias sf="php app/console"' >> ~/.bashrc
RUN echo 'alias sf3="php bin/console"' >> ~/.bashrc

RUN mkdir -p /root/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

RUN apt-get install libldap2-dev -y 
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install ldap
ENV COMPOSER_PATH "/usr/local/bin/composer"

RUN mkdir -p /var/www/symfony 

ADD composer.json /var/www/symfony/composer.json
RUN cd /var/www/symfony/ && composer update

RUN rm /var/www/symfony/composer.json
RUN cp -r /var/www/symfony/vendor /opt/.

# From here we load our application's code in, therefore the previous docker
# "layer" thats been cached will be used if possible
WORKDIR /var/www/symfony