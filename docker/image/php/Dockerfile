FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    bash \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmemcached-dev \
    libpng-dev \
    libz-dev \
    zip \
    wget

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && cd /usr/src/php/ext/memcached \
    && git checkout v3.2.0 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached

COPY --from=composer:2.3 /usr/bin/composer /usr/local/bin/composer
COPY --from=atkrad/wait4x:latest /usr/bin/wait4x /usr/local/bin/wait4x
COPY ./bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* \
    && chown -R www-data:www-data /var/www

ENV HOST_UID 1000
ENV HOST_GID 1000

CMD [ "/usr/local/bin/start" ]
