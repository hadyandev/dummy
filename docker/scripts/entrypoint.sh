#!/bin/bash

# Laravel Docker Container Entrypoint
# Simple entrypoint for www-data user (non-root)

# Don't exit on error for initial setup commands
set +e

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
    
    # Try to create directories - ignore errors if permissions don't allow
    echo "📁 Creating Laravel directories..."
    mkdir -p /var/www/storage/logs 2>/dev/null || true
    mkdir -p /var/www/storage/framework/cache 2>/dev/null || true
    mkdir -p /var/www/storage/framework/sessions 2>/dev/null || true
    mkdir -p /var/www/storage/framework/views 2>/dev/null || true
    mkdir -p /var/www/bootstrap/cache 2>/dev/null || true
    mkdir -p /var/www/vendor 2>/dev/null || true
    
    # Check if vendor folder needs installation
    if [ ! -d "/var/www/vendor" ] || [ ! -f "/var/www/vendor/autoload.php" ]; then
        echo "📦 Installing Composer dependencies..."
        
        # Try to create vendor directory with proper approach
        if [ ! -d "/var/www/vendor" ]; then
            echo "⚠️  Vendor directory doesn't exist, attempting to create..."
            mkdir -p /var/www/vendor 2>/dev/null || {
                echo "❌ Cannot create vendor directory due to permissions"
                echo "� Please run: docker-compose exec -u root app chown -R www-data:www-data /var/www"
                echo "⚠️  Continuing without composer install..."
            }
        fi
        
        # Only run composer if we can write to /var/www
        if [ -w "/var/www" ]; then
            cd /var/www && composer install --optimize-autoloader --no-interaction 2>&1 || {
                echo "⚠️  Composer install failed. This might be due to permissions."
                echo "💡 You can manually run: docker-compose exec app composer install"
            }
        else
            echo "⚠️  /var/www is not writable by www-data, skipping composer install"
            echo "💡 Fix permissions on host: sudo chown -R 33:33 ."
        fi
    else
        echo "✅ Vendor folder exists with autoload.php, skipping composer install"
    fi
    
    echo "✅ Container initialization complete"
fi

# Re-enable exit on error for main command
set -e

# Execute the main command
exec "$@"