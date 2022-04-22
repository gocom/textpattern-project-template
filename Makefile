.PHONY: start stop

all: start

start:
	docker-compose up -d

stop:
	docker-compose stop -d

help:
	@echo "Manage project"
	@echo ""
	@echo "Usage:"
	@echo "  $$ make [command]"
	@echo ""
	@echo "Commands:"
	@echo ""
	@echo "  $$ make start"
	@echo "  Starts the project"
	@echo ""
	@echo "  $$ make stop"
	@echo "  Stops the project"
	@echo ""
