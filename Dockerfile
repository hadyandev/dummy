FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor \
    && docker-php-ext-configure gd \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql pgsql pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application directory contents
COPY . /var/www

# Create necessary directories with proper permissions
RUN mkdir -p /var/www/vendor /var/www/bootstrap/cache /var/www/storage \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Install composer dependencies as www-data user
USER www-data
RUN composer install --optimize-autoloader --no-dev --no-interaction

# Install npm dependencies and build assets
RUN npm install && npm run build

# Switch back to root for final setup
USER root

# Copy entrypoint script and set permissions
COPY docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ensure www-data owns everything
RUN chown -R www-data:www-data /var/www

# Switch to www-data user for running the application
USER www-data

# Set entrypoint and default command
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]