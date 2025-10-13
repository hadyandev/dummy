#!/bin/bash

# Laravel Docker Setup Script
# Handles permissions automatically for different hosts

set -e  # Exit on any error

echo "🚀 Starting Laravel Docker Environment Setup..."

# Detect current user UID and GID
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "📋 Detected User ID: $CURRENT_UID, Group ID: $CURRENT_GID"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file from template..."
    cp .env.docker .env
fi

# Update UID and GID in .env file
echo "🔧 Updating user permissions in .env file..."
sed -i "s/UID=.*/UID=$CURRENT_UID/" .env
sed -i "s/GID=.*/GID=$CURRENT_GID/" .env

# Ensure proper ownership of the project directory
echo "📁 Setting proper file ownership..."
sudo chown -R $CURRENT_UID:$CURRENT_GID . 2>/dev/null || {
    echo "⚠️  Cannot change ownership with sudo, trying without..."
    chown -R $CURRENT_UID:$CURRENT_GID . 2>/dev/null || {
        echo "ℹ️  Ownership change skipped - continuing with current permissions"
    }
}

# Set proper permissions for Laravel directories
echo "🔐 Setting Laravel directory permissions..."
chmod -R 775 storage bootstrap/cache 2>/dev/null || {
    echo "ℹ️  Permission change failed - will be handled by container"
}

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || echo "ℹ️  No containers to stop"

# Build and start containers
echo "🏗️  Building and starting Docker containers..."
docker-compose up --build -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 15

# Check if database is accessible
echo "🔍 Testing database connection..."
while ! docker-compose exec -T app php artisan migrate:status &>/dev/null; do
    echo "⏳ Database not ready yet, waiting..."
    sleep 5
done

# Run Laravel setup commands
echo "⚙️  Setting up Laravel application..."

# Fix environment file in container if needed
docker-compose exec -T app bash -c "
    # Ensure DB_CONNECTION is pgsql
    sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=pgsql/g' /var/www/.env
    sed -i 's/DB_PORT=3306/DB_PORT=5432/g' /var/www/.env
    
    # Clear caches
    php artisan config:clear || true
    php artisan cache:clear || true
    php artisan route:clear || true
    php artisan view:clear || true
"

# Run migrations
echo "📊 Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Generate application key if needed
echo "🔑 Generating application key..."
docker-compose exec -T app bash -c "
    if ! grep -q 'APP_KEY=base64:' /var/www/.env; then
        php artisan key:generate --force
    fi
"

# Create storage link
echo "🔗 Creating storage symbolic link..."
docker-compose exec -T app php artisan storage:link 2>/dev/null || echo "ℹ️  Storage link already exists"

# Set final permissions in container
echo "🔧 Setting final permissions in container..."
docker-compose exec -T -u root app bash -c "
    chown -R $CURRENT_UID:$CURRENT_GID /var/www/storage /var/www/bootstrap/cache
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache
"

# Show container status
echo "📊 Container Status:"
docker-compose ps

# Show application URLs
echo "✅ Setup Complete!"
echo ""
echo "🌐 Application URLs:"
echo "   - Laravel App: http://localhost:8080"
echo "   - API Status: http://localhost:8080/api/status"
echo ""
echo "🗄️  Database Connection:"
echo "   - Host: localhost"
echo "   - Port: 3306 (mapped from 5432)"
echo "   - Database: laravel"
echo "   - Username: laravel"
echo "   - Password: laravel"
echo "   - Driver: PostgreSQL"
echo ""
echo "🚀 Your Laravel application is ready!"
echo ""
echo "💡 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Access container: docker-compose exec app bash"
echo "   - Run artisan: docker-compose exec app php artisan [command]"
echo "   - Stop containers: docker-compose down"