#!/bin/bash

# Laravel Artisan Wrapper for Makefile
# This script handles the artisan command arguments from make

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Check if any arguments provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Usage: make artisan <command>${RESET}"
    echo -e "${BLUE}Examples:${RESET}"
    echo "  make artisan list"
    echo "  make artisan migrate:status"  
    echo "  make artisan make:controller UserController"
    echo "  make artisan --version"
    exit 1
fi

# Run artisan command
echo -e "${GREEN}Running: php artisan $*${RESET}"
docker-compose exec app php artisan "$@"