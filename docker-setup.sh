#!/bin/bash

echo "Setting up Laravel Docker environment..."

# Copy environment file
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.docker .env
fi

# Build and start containers
echo "Building and starting Docker containers..."
docker-compose up --build -d

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 30

# Install dependencies and setup Laravel
echo "Setting up Laravel application..."
docker-compose exec app composer install
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan storage:link
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# Set permissions
echo "Setting permissions..."
docker-compose exec app chown -R www-data:www-data /var/www/storage
docker-compose exec app chown -R www-data:www-data /var/www/bootstrap/cache

echo "Setup complete!"
echo "Application is available at: http://localhost:8080"
echo "PhpMyAdmin is available at: http://localhost:8081"
echo "Database credentials:"
echo "  Host: localhost:3306"
echo "  Database: laravel" 
echo "  Username: laravel"
echo "  Password: laravel"