.PHONY: help start stop clean create-env require-install require-no-install install setup shell

HOST_UID ?= `id -u`
HOST_GID ?= `id -g`
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

install: require-no-install create-env
	$(MAKE) start
	$(MAKE) setup

vendor:
	$(PHP) composer install

setup:
	$(PHP) textpattern-download
	$(PHP) textpattern-setup
	$(MAKE) vendor

start: require-install stop
	$(COMPOSE) up -d

stop:
	docker-compose stop

clean:
	docker-compose run --rm php chown -R $(HOST_UID):$(HOST_GID) .
	$(MAKE) stop
	git clean -f -X -d
	docker-compose down --rmi 'local' --volumes

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
