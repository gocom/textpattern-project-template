.PHONY: help start stop clean create-env require-install require-no-install install textpattern-download textpattern-config shell

HOST_UID ?= `id -u`
HOST_GID ?= `id -g`
TEXTPATTERN_VERSION ?= 4.8.8
PHP = docker-compose exec -u www-data:www-data php
COMPOSE = HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker-compose

all: help

require-install:
ifeq (,$(wildcard .env))
	@echo "Project is not yet installed."
	exit 1
endif

require-no-install:
ifneq (,$(wildcard .env))
	@echo "Project is already installed."
	exit 1
endif

create-env:
ifeq (,$(wildcard .env))
	cp .env.template .env
endif

install: require-no-install textpattern-download create-env start

textpattern-download:
	curl -L "https://github.com/textpattern/textpattern/releases/download/$(TEXTPATTERN_VERSION)/textpattern-$(TEXTPATTERN_VERSION).tar.gz" --output textpattern.tar.gz
	tar -xf textpattern.tar.gz -C public/ --strip 1
	rm textpattern.tar.gz

textpattern-config:
	cp textpattern.config.php public/textpattern/config.php

start: require-install stop
	$(COMPOSE) up -d

stop: require-install
	docker-compose stop

clean:
	docker-compose down -rmi 'local' --volumes
	rm -rf .env

shell: require-install
	$(PHP) bash

help:
	@echo "Manage project"
	@echo ""
	@echo "Usage:"
	@echo "  $$ make [command]"
	@echo ""
	@echo "Commands:"
	@echo ""
	@echo "  $$ make install"
	@echo "  Installs the project"
	@echo ""
	@echo "  $$ make clean"
	@echo "  Uninstall the project"
	@echo ""
	@echo "  $$ make start"
	@echo "  Starts the project"
	@echo ""
	@echo "  $$ make stop"
	@echo "  Stops the project"
	@echo ""
	@echo "  $$ make shell"
	@echo "  Login to PHP service"
	@echo ""
