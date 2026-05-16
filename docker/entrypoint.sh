#!/bin/sh
set -e

# Ensure environment file exists
if [ ! -f /var/www/html/.env ]; then
  if [ -f /var/www/html/.env.example ]; then
    cp /var/www/html/.env.example /var/www/html/.env
  fi
fi

cd /var/www/html

# Install composer dependencies if vendor is missing
if [ ! -d vendor ] || [ ! -f vendor/autoload.php ]; then
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Run Laravel setup only when the framework files exist.
if [ -f artisan ]; then
  # Generate app key if missing
  if [ -z "$(php -r "echo getenv('APP_KEY');")" ]; then
    php artisan key:generate || true
  fi

  # Wait for database to be ready (if mysql client exists)
  if command -v mysqladmin >/dev/null 2>&1; then
    echo "Waiting for MySQL at ${DB_HOST:-mysql}:${DB_PORT:-3306}..."
    until mysqladmin ping -h"${DB_HOST:-mysql}" -P"${DB_PORT:-3306}" --silent; do
      sleep 1
    done
  fi

  # Run migrations (non-interactive)
  php artisan migrate --force || true
fi

# Ensure correct permissions
mkdir -p storage bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views
chown -R www-data:www-data storage bootstrap/cache || true

# Exec the container CMD
exec "$@"
