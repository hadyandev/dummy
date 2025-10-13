#!/bin/bash

# Laravel Artisan Helper Script
# Usage: ./artisan.sh [command]
# Examples:
#   ./artisan.sh list
#   ./artisan.sh migrate:status
#   ./artisan.sh make:controller UserController

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Check if docker-compose is running
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Docker containers are not running. Starting them...${RESET}"
    docker-compose up -d
    echo -e "${GREEN}✅ Containers started${RESET}"
fi

# Check if any arguments provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Usage: ./artisan.sh <command>${RESET}"
    echo -e "${BLUE}Examples:${RESET}"
    echo "  ./artisan.sh list"
    echo "  ./artisan.sh migrate:status"
    echo "  ./artisan.sh make:controller UserController"
    echo "  ./artisan.sh --version"
    exit 1
fi

# Run artisan command
echo -e "${GREEN}🎯 Running: php artisan $*${RESET}"
docker-compose exec app php artisan "$@"