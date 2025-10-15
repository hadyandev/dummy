# Dummy Izin Docker Development Environment
# 
# Usage: make [target]
#
# Common targets:
#   setup     - Initial setup (build, start, migrate)
#   start     - Start containers  
#   stop      - Stop containers
#   restart   - Restart containers
#   logs      - View logs from all containers
#   shell     - Access app container shell
#   ps        - Show container status

.DEFAULT_GOAL := help
.PHONY: help setup start stop restart build logs logs-app logs-queue logs-scheduler logs-web logs-db shell ps migrate artisan clean

help: ## Show this help message
	@echo "Dummy Izin Docker Environment"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make setup          # Initial setup"
	@echo "  make start          # Start containers"
	@echo "  make logs           # View logs"
	@echo "  make shell          # Access container shell"
	@echo "  make artisan CMD=\"migrate:status\""

setup: ## Initial setup (build, start, migrate)
	@echo "=> Building Docker images..."
	docker-compose build
	@echo "=> Starting containers..."
	docker-compose up -d
	@echo "=> Waiting for containers..."
	@sleep 10
	@echo "=> Running migrations..."
	docker-compose exec app php artisan migrate --force || true
	@echo ""
	@echo "Setup complete!"
	@if [ -f .env ]; then \
		WEBSERVER_PORT=$$(grep "^WEBSERVER_PORT=" .env | cut -d'=' -f2 | tr -d ' '); \
		DB_PORT_EXTERNAL=$$(grep "^DB_PORT_EXTERNAL=" .env | cut -d'=' -f2 | tr -d ' '); \
		APP_URL=$$(grep "^APP_URL=" .env | cut -d'=' -f2 | tr -d ' '); \
		echo "Application: $${APP_URL:-http://localhost:$${WEBSERVER_PORT:-8090}}"; \
		echo "Database: PostgreSQL on port $${DB_PORT_EXTERNAL:-5433}"; \
	else \
		echo "Application: http://localhost:8090"; \
		echo "Database: PostgreSQL on port 5433"; \
	fi

start: ## Start containers
	@echo "=> Starting containers..."
	docker-compose up -d

stop: ## Stop containers
	@echo "=> Stopping containers..."
	docker-compose down

restart: ## Restart containers
	@echo "=> Restarting containers..."
	docker-compose restart

build: ## Rebuild containers
	@echo "=> Rebuilding containers..."
	docker-compose up --build -d

logs: ## View logs from all containers
	docker-compose logs -f

logs-app: ## View app container logs only
	docker-compose logs -f app

logs-queue: ## View queue worker logs only
	docker-compose logs -f queue

logs-scheduler: ## View scheduler logs only
	docker-compose logs -f scheduler

logs-web: ## View nginx webserver logs only
	docker-compose logs -f webserver

logs-db: ## View database logs only
	docker-compose logs -f db

shell: ## Access app container shell
	docker-compose exec app bash

ps: ## Show container status
	docker-compose ps

migrate: ## Run database migrations
	@echo "=> Running migrations..."
	docker-compose exec app php artisan migrate

migrate-fresh: ## Fresh migration with seed
	@echo "=> Running fresh migration..."
	docker-compose exec app php artisan migrate:fresh --seed

tinker: ## Start Laravel Tinker
	docker-compose exec app php artisan tinker

test: ## Run tests
	docker-compose exec app php artisan test

artisan: ## Run artisan command (use: make artisan CMD="command")
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make artisan CMD=\"command\""; \
		echo "Example: make artisan CMD=\"migrate:status\""; \
		exit 1; \
	fi
	docker-compose exec app php artisan $(CMD)

composer: ## Run composer command (use: make composer CMD="install")
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make composer CMD=\"command\""; \
		echo "Example: make composer CMD=\"require package/name\""; \
		exit 1; \
	fi
	docker-compose exec app composer $(CMD)

cache-clear: ## Clear all Laravel caches
	@echo "=> Clearing caches..."
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

db-shell: ## Access database shell
	@if [ -f .env ]; then \
		DB_USERNAME=$$(grep "^DB_USERNAME=" .env | cut -d'=' -f2 | tr -d ' '); \
		DB_DATABASE=$$(grep "^DB_DATABASE=" .env | cut -d'=' -f2 | tr -d ' '); \
		docker-compose exec db psql -U $${DB_USERNAME:-dummy} -d $${DB_DATABASE:-dummy}; \
	else \
		docker-compose exec db psql -U dummy -d dummy; \
	fi

clean: ## Remove containers and volumes
	@echo "=> Cleaning up..."
	docker-compose down -v --remove-orphans

info: ## Show application info
	@echo ""
	@echo "=== Dummy Izin Environment ==="
	@echo ""
	@if [ -f .env ]; then \
		WEBSERVER_PORT=$$(grep "^WEBSERVER_PORT=" .env | cut -d'=' -f2 | tr -d ' '); \
		DB_PORT_EXTERNAL=$$(grep "^DB_PORT_EXTERNAL=" .env | cut -d'=' -f2 | tr -d ' '); \
		DB_DATABASE=$$(grep "^DB_DATABASE=" .env | cut -d'=' -f2 | tr -d ' '); \
		DB_USERNAME=$$(grep "^DB_USERNAME=" .env | cut -d'=' -f2 | tr -d ' '); \
		APP_URL=$$(grep "^APP_URL=" .env | cut -d'=' -f2 | tr -d ' '); \
		echo "Application: $${APP_URL:-http://localhost:$${WEBSERVER_PORT:-8090}}"; \
		echo "Database: localhost:$${DB_PORT_EXTERNAL:-5433}"; \
		echo "DB Name: $${DB_DATABASE:-dummy}"; \
		echo "DB User: $${DB_USERNAME:-dummy}"; \
	else \
		echo "Application: http://localhost:8090 (default)"; \
		echo "Database: localhost:5433 (default)"; \
		echo "DB Name: dummy (default)"; \
		echo "DB User: dummy (default)"; \
		echo ""; \
		echo "⚠️  .env file not found. Run: cp .env.example .env"; \
	fi
	@echo ""
	@echo "Container Status:"
	@docker-compose ps

# Catch-all for artisan commands without CMD parameter
%:
	@: