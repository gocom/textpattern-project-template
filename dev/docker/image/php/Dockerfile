FROM golang:1.27-trixie AS mailhog

WORKDIR /usr/src/app

RUN go install github.com/mailhog/mhsendmail@v0.2.0

FROM php:8.5-fpm-trixie

RUN apt-get update && apt-get install -y \
    bash \
    git \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmemcached-dev \
    libpng-dev \
    libz-dev \
    libzip-dev \
    zip \
    wget

RUN docker-php-ext-install intl mysqli pdo pdo_mysql zip

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

COPY --from=composer:2.10.3 /usr/bin/composer /usr/local/bin/composer
COPY --from=ghcr.io/php/pie:1.5.0-bin /pie /usr/local/bin/pie
COPY --from=atkrad/wait4x:latest /usr/bin/wait4x /usr/local/bin/wait4x
COPY --from=mailhog /go/bin/mhsendmail /usr/local/bin/mhsendmail

RUN pie install php-memcached/php-memcached \
    && docker-php-ext-enable memcached

COPY ./bin/ /usr/local/bin/
COPY ./conf/ /usr/local/etc/php/conf.d/

RUN chmod +x /usr/local/bin/* \
    && chown -R www-data:www-data /var/www

ENV HOST_UID 1000
ENV HOST_GID 1000

CMD [ "/usr/local/bin/start" ]
