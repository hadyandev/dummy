#!/bin/bash

# Laravel Docker Setup Script (Simplified)
# For www-data user approach (no UID/GID complexity)

set -e  # Exit on any error

echo "🚀 Starting Laravel Docker Environment Setup..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file from example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created from .env.example"
    else
        echo "❌ .env.example not found. Please create .env manually."
        exit 1
    fi
else
    echo "✅ .env file already exists"
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || echo "ℹ️  No containers to stop"

# Build Docker images
echo "🏗️  Building Docker images (this may take a few minutes)..."
docker-compose build --no-cache app

# Start containers
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Test database connection
echo "🔍 Testing database connection..."
max_attempts=12
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T app php artisan migrate:status &>/dev/null; then
        echo "✅ Database is ready!"
        break
    fi
    attempt=$((attempt + 1))
    echo "⏳ Waiting for database... (attempt $attempt/$max_attempts)"
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database connection timeout. Please check your configuration."
    echo "💡 Try: docker-compose logs db"
    exit 1
fi

# Clear Laravel caches
echo "🧹 Clearing Laravel caches..."
docker-compose exec -T app php artisan config:clear || true
docker-compose exec -T app php artisan cache:clear || true
docker-compose exec -T app php artisan route:clear || true
docker-compose exec -T app php artisan view:clear || true

# Run migrations
echo "📊 Running database migrations..."
docker-compose exec -T app php artisan migrate --force || echo "⚠️  Migrations may have already run"

# Generate application key if needed
echo "🔑 Checking application key..."
docker-compose exec -T app bash -c "
    if ! grep -q 'APP_KEY=base64:' /var/www/.env; then
        echo '🔑 Generating application key...'
        php artisan key:generate --force
    else
        echo '✅ Application key already exists'
    fi
"

# Create storage link
echo "🔗 Creating storage symbolic link..."
docker-compose exec -T app php artisan storage:link 2>/dev/null || echo "ℹ️  Storage link already exists"

# Show container status
echo ""
echo "📊 Container Status:"
docker-compose ps

# Read configuration from .env
WEBSERVER_PORT=$(grep "^WEBSERVER_PORT=" .env | cut -d'=' -f2 || echo "8090")
DB_PORT_EXTERNAL=$(grep "^DB_PORT_EXTERNAL=" .env | cut -d'=' -f2 || echo "5433")
DB_DATABASE=$(grep "^DB_DATABASE=" .env | cut -d'=' -f2 || echo "dummy")
DB_USERNAME=$(grep "^DB_USERNAME=" .env | cut -d'=' -f2 || echo "dummy")

# Show application information
echo ""
echo "✅ Setup Complete!"
echo ""
echo "🌐 Application URL:"
echo "   - Web App: http://localhost:$WEBSERVER_PORT"
echo ""
echo "🗄️  Database Connection (from host):"
echo "   - Host:     localhost"
echo "   - Port:     $DB_PORT_EXTERNAL"
echo "   - Database: $DB_DATABASE"
echo "   - Username: $DB_USERNAME"
echo "   - Driver:   PostgreSQL"
echo ""
echo "🚀 Your Laravel application is ready!"
echo ""
echo "💡 Useful commands:"
echo "   - View logs:        make logs"
echo "   - Access container: make shell"
echo "   - Run migrations:   make migrate"
echo "   - Stop containers:  make stop"
echo "   - Clean up:         make clean"
echo ""
