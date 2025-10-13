# Dummy Izin Docker Development Environment
# 
# Usage: make [target]
#
# Common targets:
#   setup     - Initial setup (auto-detect permissions)
#   start     - Start containers  
#   stop      - Stop containers
#   restart   - Restart containers
#   logs      - View logs
#   shell     - Access app container shell
#   test      - Run tests
#   clean     - Clean up everything

.DEFAULT_GOAL := help
.PHONY: help setup start stop restart logs shell test clean status migrate artisan npm

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Dummy Izin Docker Environment$(RESET)"
	@echo ""
	@echo "$(GREEN)Available commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-12s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(BLUE)Examples:$(RESET)"
	@echo "  make setup     # Initial setup with automatic permission handling"
	@echo "  make start     # Start all containers"
	@echo "  make logs      # View container logs"
	@echo "  make shell     # Access Dummy container"

setup: ## Run initial setup (handles permissions automatically)
	@echo "$(GREEN)🚀 Running Dummy Docker setup...$(RESET)"
	chmod +x setup.sh
	./setup.sh

start: ## Start Docker containers
	@echo "$(GREEN)🐳 Starting Docker containers...$(RESET)"
	docker-compose up -d

stop: ## Stop Docker containers  
	@echo "$(YELLOW)🛑 Stopping Docker containers...$(RESET)"
	docker-compose down

restart: ## Restart Docker containers
	@echo "$(YELLOW)🔄 Restarting Docker containers...$(RESET)"
	docker-compose restart

build: ## Rebuild Docker containers
	@echo "$(BLUE)🏗️ Rebuilding Docker containers...$(RESET)"
	docker-compose up --build -d

logs: ## View container logs
	logs: ## Show application logs
	@echo "$(BLUE)� Showing application logs...$(RESET)"
	docker-compose exec app tail -f storage/logs/laravel.log

shell: ## Access container shell
	@echo "$(BLUE)🐚 Opening container shell...$(RESET)"
	docker-compose exec app bash

test: ## Run tests
	@echo "$(BLUE)🧪 Running tests...$(RESET)"
	docker-compose exec app php artisan test

tinker: ## Start Laravel Tinker
	@echo "$(BLUE)🔧 Starting Laravel Tinker...$(RESET)"
	docker-compose exec app php artisan tinker

clear-cache: ## Clear all Laravel caches
	@echo "$(YELLOW)🧹 Clearing Laravel caches...$(RESET)"
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

status: ## Show container status
	@echo "$(BLUE)📊 Container Status:$(RESET)"
	docker-compose ps

shell: ## Access app container shell
	@echo "$(GREEN)🐚 Accessing app container...$(RESET)"
	docker-compose exec app bash

migrate: ## Run database migrations
	@echo "$(GREEN)📊 Running database migrations...$(RESET)"
	docker-compose exec app php artisan migrate

migrate-status: ## Show migration status
	@echo "$(BLUE)📋 Checking migration status...$(RESET)"
	docker-compose exec app php artisan migrate:status

make-migration: ## Create new migration (use: make make-migration NAME="create_users_table")
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)⚠️  Usage: make make-migration NAME=\"migration_name\"$(RESET)"; \
		echo "$(BLUE)Example: make make-migration NAME=\"create_users_table\"$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)📝 Creating migration: $(NAME)$(RESET)"
	docker-compose exec app php artisan make:migration $(NAME)

make-controller: ## Create new controller (use: make make-controller NAME="UserController")
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)⚠️  Usage: make make-controller NAME=\"ControllerName\"$(RESET)"; \
		echo "$(BLUE)Example: make make-controller NAME=\"UserController\"$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)🎛️  Creating controller: $(NAME)$(RESET)"
	docker-compose exec app php artisan make:controller $(NAME)

make-model: ## Create new model (use: make make-model NAME="User")
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)⚠️  Usage: make make-model NAME=\"ModelName\"$(RESET)"; \
		echo "$(BLUE)Example: make make-model NAME=\"User\"$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)📦 Creating model: $(NAME)$(RESET)"
	docker-compose exec app php artisan make:model $(NAME)

artisan: ## Run artisan command (use: make artisan CMD="migrate:status")
	@echo "$(GREEN)🎯 Running artisan command...$(RESET)"
	@if [ -z "$(CMD)" ]; then \
		echo "$(YELLOW)⚠️  Usage: make artisan CMD=\"command\"$(RESET)"; \
		echo "$(BLUE)Examples:$(RESET)"; \
		echo "  make artisan CMD=\"migrate\""; \
		echo "  make artisan CMD=\"migrate:status\""; \
		echo "  make artisan CMD=\"audit:show --limit=5\""; \
		exit 1; \
	fi
	docker-compose exec app php artisan $(CMD)

npm: ## Run npm command (use: make npm CMD="install")
	@echo "$(GREEN)📦 Running npm command...$(RESET)"
	docker-compose exec app npm $(CMD)

fresh: ## Fresh database migration with seeding
	@echo "$(GREEN)🗄️ Fresh database migration...$(RESET)"
	docker-compose exec app php artisan migrate:fresh --seed

fix-permissions: ## Fix file permissions (both host and container)
	@echo "$(YELLOW)🔧 Fixing host file permissions...$(RESET)"
	sudo chown -R $(shell id -u):$(shell id -g) .
	@echo "$(YELLOW)🔧 Fixing container file permissions...$(RESET)"
	docker-compose exec app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache || echo "Container not running"
	docker-compose exec app chmod -R 775 /var/www/storage /var/www/bootstrap/cache || echo "Container not running"
	@echo "$(GREEN)✅ All permissions fixed!$(RESET)"

fix-host-permissions: ## Fix host file permissions only
	@echo "$(YELLOW)🔧 Fixing host file permissions...$(RESET)"
	sudo chown -R $(shell id -u):$(shell id -g) .
	@echo "$(GREEN)✅ Host permissions fixed!$(RESET)"

fix-ownership: ## Fix file ownership issues (comprehensive)
	@echo "$(YELLOW)🔧 Running comprehensive ownership fix...$(RESET)"
	./fix-ownership.sh

clean: ## Clean up containers, images, and volumes
	@echo "$(RED)🧹 Cleaning up Docker resources...$(RESET)"
	docker-compose down -v --remove-orphans
	docker system prune -f

health: ## Check application health
	@echo "$(BLUE)🏥 Checking application health...$(RESET)"
	@curl -s http://localhost:8080/api/status | jq . || curl http://localhost:8080/api/status
	@echo ""
	@echo "$(GREEN)✅ Application is healthy!$(RESET)"

db-shell: ## Access database shell
	@echo "$(GREEN)🗄️ Accessing PostgreSQL shell...$(RESET)"
	docker-compose exec db psql -U laravel -d laravel

backup-db: ## Backup database
	@echo "$(BLUE)💾 Creating database backup...$(RESET)"
	docker-compose exec db pg_dump -U laravel laravel > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Database backup created!$(RESET)"

install: setup ## Alias for setup

info: ## Show application information
	@echo "$(BLUE)ℹ️  Dummy Izin Docker Environment Information$(RESET)"
	@echo ""
	@echo "$(GREEN)📱 Application URLs:$(RESET)"
	@echo "  🌐 Dummy Izin App: http://localhost:8080"
	@echo "  🔌 API Status:  http://localhost:8080/api/status"
	@echo ""
	@echo "$(GREEN)🗄️ Database Connection:$(RESET)"
	@echo "  📍 Host:     localhost"
	@echo "  🔌 Port:     3306 (mapped from 5432)"
	@echo "  💾 Database: laravel"
	@echo "  👤 Username: laravel"
	@echo "  🔑 Password: laravel"
	@echo "  🔧 Driver:   PostgreSQL"
	@echo ""
	@echo "$(GREEN)📋 Container Status:$(RESET)"
	@docker-compose ps

# Catch-all target to prevent make from complaining about unknown targets when using make artisan
%:
	@: