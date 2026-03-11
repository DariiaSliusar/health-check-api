#!/bin/sh
set -e

echo "🚀 Starting Laravel application setup..."

# Встановлення Composer залежностей
if [ ! -d "/var/www/vendor" ]; then
    echo "📦 Installing Composer dependencies..."
    composer install --prefer-dist --no-interaction --optimize-autoloader --no-dev
else
    echo "✅ Vendor directory exists, skipping composer install"
fi

# Створення .env файлу якщо не існує
if [ ! -f /var/www/.env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp /var/www/.env.example /var/www/.env
fi

# Генерація ключа додатку якщо не встановлений
if grep -q "APP_KEY=$" /var/www/.env || ! grep -q "APP_KEY=" /var/www/.env; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force
else
    echo "✅ Application key already set"
fi

# Налаштування прав доступу
echo "🔐 Setting permissions..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Очікування готовності MySQL з retry логікою
echo "⏳ Waiting for MySQL to be ready..."
max_tries=60
counter=0
until php artisan db:show > /dev/null 2>&1 || [ $counter -eq $max_tries ]; do
    counter=$((counter+1))
    if [ $((counter % 10)) -eq 0 ]; then
        echo "Still waiting for database... ($counter/$max_tries)"
    fi
    sleep 2
done

if [ $counter -eq $max_tries ]; then
    echo "⚠️  Warning: Could not verify database connection"
    echo "Will attempt migrations anyway..."
fi

# Завжди намагаємося запустити міграції
echo "🗃️  Running database migrations..."
if php artisan migrate --force 2>/dev/null; then
    echo "✅ Migrations completed successfully"
else
    echo "⚠️  Migrations failed or already up to date"
fi

echo "✨ Laravel application is ready!"

exec "$@"
