#!/bin/bash

# Laravel Docker Container Entrypoint
# Simple entrypoint for www-data user (non-root)

set -e

echo "🐳 Starting Laravel container..."

# Check if running as www-data (should be UID 33)
CURRENT_USER=$(whoami)
echo "� Running as user: $CURRENT_USER (UID: $(id -u))"

# Create directories if they don't exist (www-data should have permission via volumes)
if [ "$1" = 'php-fpm' ]; then
    echo "🔧 Setting up Laravel application..."
    
    # Fix git safe.directory issue (allow www-data to use git in mounted volume)
    git config --global --add safe.directory /var/www 2>/dev/null || true
    
    # Create directories if they don't exist (will work if volume is mounted with proper permissions)
    mkdir -p /var/www/storage/logs 2>/dev/null || echo "⚠️  Cannot create logs directory (may already exist)"
    mkdir -p /var/www/storage/framework/cache 2>/dev/null || echo "⚠️  Cannot create cache directory (may already exist)"
    mkdir -p /var/www/storage/framework/sessions 2>/dev/null || echo "⚠️  Cannot create sessions directory (may already exist)"
    mkdir -p /var/www/storage/framework/views 2>/dev/null || echo "⚠️  Cannot create views directory (may already exist)"
    mkdir -p /var/www/bootstrap/cache 2>/dev/null || echo "⚠️  Cannot create bootstrap cache directory (may already exist)"
    
    # Install composer dependencies if vendor folder doesn't exist or is empty
    if [ ! -d "/var/www/vendor" ] || [ -z "$(ls -A /var/www/vendor 2>/dev/null)" ]; then
        echo "📦 Installing Composer dependencies..."
        composer install --optimize-autoloader --no-interaction
        echo "✅ Composer dependencies installed"
    else
        echo "✅ Vendor folder exists, skipping composer install"
    fi
    
    echo "✅ Container initialization complete"
fi

# Execute the main command
exec "$@"