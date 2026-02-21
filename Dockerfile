FROM php:8.2-apache
# Force PHP error display (temporary for debugging)
RUN echo "display_errors=On" >> /usr/local/etc/php/php.ini \
 && echo "display_startup_errors=On" >> /usr/local/etc/php/php.ini \
 && echo "error_reporting=E_ALL" >> /usr/local/etc/php/php.ini

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by OJS
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
        mbstring \
        bcmath \
        intl\
        ftp

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy OJS source
COPY . /var/www/html
# Create config.inc.php from template
RUN cp config.TEMPLATE.inc.php config.inc.php
RUN chown -R www-data:www-data /var/www/html

# Install OJS vendor dependencies (CORRECT PATH)
RUN composer install --no-dev --optimize-autoloader --working-dir=lib/pkp

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Apache directory permissions
RUN sed -i 's|/var/www/html|/var/www/html|g' /etc/apache2/sites-available/000-default.conf \
 && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/c\<Directory /var/www/html>\n    AllowOverride All\n    Require all granted\n</Directory>' /etc/apache2/apache2.conf

EXPOSE 80
