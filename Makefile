.PHONY: artifact deploy help start stop clean create-env require-install install setup shell build hosts
.ONESHELL:
.SHELLFLAGS = -ec

HOST_UID ?= `id -u`
HOST_GID ?= `id -g`
PHP = docker compose exec -u www-data:www-data php
COMPOSE = HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker compose
BUILD = $(COMPOSE) run --rm build
NPM = npm

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
ifeq (,$(wildcard node_modules))
	@. ./dev/hook/nvm.sh
	$(NPM) install
endif

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
	@. ./dev/hook/nvm.sh
	$(NPM) run build

test: node_modules
	@. ./dev/hook/nvm.sh
	$(NPM) run test

lint: node_modules
	@. ./dev/hook/nvm.sh
	$(NPM) run lint

lint-fix: node_modules
	@. ./dev/hook/nvm.sh
	$(NPM) run lint:fix

hosts:
	$(PHP) bin/hosts

artifact: create-env
	mkdir -p build/public
	$(BUILD) textpattern-download
	$(MAKE) build
	cp -R themes composer.json composer.lock build
	cp -R public/assets build/public

deploy: create-env
	@./bin/deploy

help:
	@echo "Manage project"
	@echo ""
	@echo "Usage:"
	@echo "  $$ make [command] ["
	@echo "    DEPLOY_USER=<user>"
	@echo "    DEPLOY_HOST=<host>"
	@echo "    DEPLOY_REMOTE_PUBLIC_PATH=<directory>"
	@echo "    DEPLOY_REMOTE_PATH=<directory>"
	@echo "    HOST_UID=<uid>"
	@echo "    HOST_GID=<gid>"
	@echo "  ]"
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
	@echo "  $$ make lint"
	@echo "  Run linters"
	@echo ""
	@echo "  $$ make test"
	@echo "  Run test suite"
	@echo ""
	@echo "  $$ make artifact"
	@echo "  Build deployment artifact"
	@echo ""
