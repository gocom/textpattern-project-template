.PHONY: help start stop clean create-env require-install install setup shell build node hosts

HOST_UID ?= `id -u`
HOST_GID ?= `id -g`
PHP = docker compose exec -u www-data:www-data php
COMPOSE = HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker compose
NODE = $(COMPOSE) run --rm node

all: help

require-install:
ifeq (,$(wildcard .env))
	@echo "Project is not yet installed."
	exit 1
endif

create-env:
ifeq (,$(wildcard .env))
	cp .env.template .env
endif

install: create-env
	$(MAKE) start
	$(MAKE) setup

vendor:
	$(PHP) composer install

node_modules:
	$(NODE) npm install

setup:
	$(PHP) textpattern-download
	$(PHP) textpattern-setup
	$(MAKE) vendor
	$(MAKE) build

start: stop
	$(COMPOSE) up -d

stop:
	docker-compose stop

clean:
	docker-compose run --rm php chown -R $(HOST_UID):$(HOST_GID) .
	$(MAKE) stop
	git clean -f -X -d
	docker-compose down --rmi 'local' --volumes

shell:
	$(PHP) bash

build: node_modules
	$(NODE) npm run build

node:
	$(NODE) bash

test: require-install
	$(NODE) npm run test

lint: require-install
	$(NODE) npm run lint

lint-fix: require-install
	$(NODE) npm run lint:fix

hosts:
	$(PHP) bin/hosts

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
	@echo "  $$ make hosts"
	@echo "  Prints hosts mapping"
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
