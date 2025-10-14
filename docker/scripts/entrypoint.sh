#!/bin/bash

# Laravel Docker Container Entrypoint
# Simple entrypoint for www-data user (non-root)
# Vendor is in separate Docker volume - no permission issues!

set -e

echo "🐳 Starting Laravel container..."

# Check if running as www-data (should be UID 33)
CURRENT_USER=$(whoami)
echo "👤 Running as user: $CURRENT_USER (UID: $(id -u))"

# Main setup for php-fpm
if [ "$1" = 'php-fpm' ]; then
    echo "🔧 Setting up Laravel application..."
    
    # Fix git safe.directory issue (allow www-data to use git in mounted volume)
    git config --global --add safe.directory /var/www 2>/dev/null || true
    git config --global --add safe.directory '*' 2>/dev/null || true
    
    # Create Laravel directories (these are bind-mounted, might have permission issues)
    echo "📁 Creating Laravel directories..."
    mkdir -p /var/www/storage/logs 2>/dev/null || true
    mkdir -p /var/www/storage/framework/cache 2>/dev/null || true
    mkdir -p /var/www/storage/framework/sessions 2>/dev/null || true
    mkdir -p /var/www/storage/framework/views 2>/dev/null || true
    mkdir -p /var/www/bootstrap/cache 2>/dev/null || true
    
    # Install composer dependencies if vendor folder is empty
    # Vendor is in Docker volume, so www-data always has write access
    if [ ! -f "/var/www/vendor/autoload.php" ]; then
        echo "📦 Installing Composer dependencies..."
        cd /var/www && composer install --optimize-autoloader --no-interaction
        echo "✅ Composer dependencies installed"
    else
        echo "✅ Vendor folder ready"
    fi
    
    echo "✅ Container initialization complete"
fi

# Execute the main command
exec "$@"
