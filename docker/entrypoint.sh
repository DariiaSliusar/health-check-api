#!/bin/sh
set -e

if [ ! -f /var/www/.env ]; then
    cp /var/www/.env.example /var/www/.env
fi

php artisan key:generate --force
php artisan migrate --force

exec "$@"
