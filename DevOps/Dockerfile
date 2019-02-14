FROM php:7.3.2-apache

# RUN echo "Install libs & PHP extensions"
RUN apt-get update && apt-get install -y \
    vim \
    zip \
    libzip-dev \
    git \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    sudo

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
    zip \
    pdo_mysql \
    gd

RUN echo "Install Composer" \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

ADD ./DevOps/php.ini /usr/local/etc/php/php.ini
COPY ./DevOps/server.conf /etc/apache2/sites-available/000-default.conf
COPY ./DevOps/ports.conf /etc/apache2/ports.conf

WORKDIR /var/www/html/

RUN mkdir -p var/log var/cache && chown -R www-data:www-data /var/www/ var/log var/cache && \
    chmod -R a+rw var/log var/cache

USER www-data:www-data

ADD --chown=www-data:www-data ./server/bin /var/www/html/bin
ADD --chown=www-data:www-data ./server/composer.json ./server/composer.lock ./server/symfony.lock /var/www/html/

RUN composer install --verbose --prefer-dist --no-interaction --no-dev --optimize-autoloader --no-suggest --no-scripts

ADD --chown=www-data:www-data ./server/cli /var/www/html/cli
ADD --chown=www-data:www-data ./server/config /var/www/html/config
ADD --chown=www-data:www-data ./server/public /var/www/html/public
ADD --chown=www-data:www-data ./server/src /var/www/html/src
ADD --chown=www-data:www-data ./server/templates /var/www/html/templates
ADD --chown=www-data:www-data ./server/translations /var/www/html/translations

RUN composer dump-autoload

EXPOSE 8080
CMD ["apache2-foreground"]
