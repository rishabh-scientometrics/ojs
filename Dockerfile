FROM php:8.1-apache

# Install system dependencies (IMPORTANT: includes libpq-dev)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql zip gd mbstring

# Enable Apache rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy OJS source
COPY . /var/www/html

# Permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port
EXPOSE 80
