#!/bin/bash

# Laravel Docker Container Entrypoint
# Handles permissions and Laravel setup automatically

set -e

echo "🐳 Starting Laravel container..."

# Fix ownership and permissions if needed
if [ "$1" = 'php-fpm' ]; then
    echo "🔧 Checking and fixing permissions..."
    
    # Create directories if they don't exist
    mkdir -p /var/www/storage/logs
    mkdir -p /var/www/storage/framework/cache
    mkdir -p /var/www/storage/framework/sessions
    mkdir -p /var/www/storage/framework/views
    mkdir -p /var/www/bootstrap/cache
    
    # Get the user ID from environment or use default
    USER_ID=${UID:-1000}
    GROUP_ID=${GID:-1000}
    
    # Check if user needs to be created or modified
    if ! getent passwd laravel > /dev/null 2>&1; then
        echo "👤 Creating user 'laravel' with UID:$USER_ID, GID:$GROUP_ID"
        groupadd -g $GROUP_ID laravel 2>/dev/null || true
        useradd -u $USER_ID -g $GROUP_ID -m laravel 2>/dev/null || true
    else
        # User exists, check if UID/GID match
        CURRENT_UID=$(id -u laravel)
        CURRENT_GID=$(id -g laravel)
        
        if [ "$CURRENT_UID" != "$USER_ID" ] || [ "$CURRENT_GID" != "$GROUP_ID" ]; then
            echo "👤 Updating user 'laravel' UID:$USER_ID, GID:$GROUP_ID"
            groupmod -g $GROUP_ID laravel 2>/dev/null || true
            usermod -u $USER_ID -g $GROUP_ID laravel 2>/dev/null || true
        fi
    fi
    
    # Fix ownership and permissions
    echo "🔐 Setting proper permissions..."
    # Set ownership for both laravel user and www-data (PHP-FPM user)
    chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
    chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
    
    # Ensure www-data can write to critical directories
    chgrp -R www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
    
    # Ensure .env file has correct database settings if needed
    if [ -f /var/www/.env ]; then
        # Fix common database configuration issues
        if grep -q "DB_CONNECTION=mysql" /var/www/.env; then
            echo "🔄 Fixing database configuration in .env file..."
            sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=pgsql/' /var/www/.env
            sed -i 's/DB_PORT=3306/DB_PORT=5432/' /var/www/.env
        fi
    fi
    
    echo "✅ Container initialization complete"
fi

# Execute the main command
exec "$@"