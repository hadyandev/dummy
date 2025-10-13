FROM php:8.2-fpm

# Arguments for user ID and group ID
ARG UID=1000
ARG GID=1000

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

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Create necessary directories with proper permissions
RUN mkdir -p /var/www/vendor /var/www/bootstrap/cache /var/www/storage \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage /var/www/bootstrap/cache

# Install composer dependencies as root first
RUN composer install --optimize-autoloader --no-dev --no-interaction

# Install npm dependencies and build assets
RUN npm install && npm run build

# Create user with same UID/GID as host user
RUN groupadd -g ${GID} laravel \
    && useradd -u ${UID} -g ${GID} -m laravel \
    && usermod -aG www-data laravel

# Copy entrypoint script
COPY docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Change ownership after installation
RUN chown -R ${UID}:${GID} /var/www \
    && chmod -R 755 /var/www/storage /var/www/bootstrap/cache

# Create laravel user with proper UID/GID (will be fixed by entrypoint if needed)
RUN groupadd -g ${GID} laravel 2>/dev/null || true \
    && useradd -u ${UID} -g ${GID} -m laravel 2>/dev/null || true \
    && usermod -aG www-data laravel

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm"]