#syntax=docker/dockerfile:1.4

# Versions
FROM dunglas/frankenphp:latest-alpine AS frankenphp_upstream
FROM composer/composer:2-bin AS composer_upstream


# The different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# Base FrankenPHP image
FROM frankenphp_upstream AS frankenphp_base

WORKDIR /app

# persistent / runtime deps
# hadolint ignore=DL3018
RUN apk add --no-cache \
		acl \
		file \
		gettext \
		git \
        build-base \
        zsh \
        shadow \
	;

# Symfony cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | sh && \
  apk add symfony-cli && \
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN set -eux; \
	install-php-extensions \
		apcu \
		intl \
		opcache \
		zip \
    	pdo_pgsql \
	;

RUN curl "https://castor.jolicode.com/install" | bash \
    && sudo mv $HOME/.local/bin/castor /usr/local/bin/castor \
    && sudo chmod +x /usr/local/bin/castor

COPY --link frankenphp/conf.d/app.ini $PHP_INI_DIR/conf.d/

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

COPY --from=composer_upstream --link /composer /usr/bin/composer

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
