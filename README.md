# Health Check API

Laravel проект з Docker підтримкою.

## Запуск

```bash
cd health-check-api
docker compose up -d
```

Додаток буде доступний на http://localhost:8080

Перший запуск займає 60-90 секунд для встановлення залежностей.

## Що відбувається автоматично

- Встановлення Composer залежностей
- Створення .env файлу
- Генерація APP_KEY
- Налаштування прав доступу
- Виконання міграцій бази даних

## API

**GET** `/api/v1/health-check`

Перевірка стану API та підключення до сервісів.

**Вимоги:**
- Throttle: 60 запитів/хвилину
- Обов'язковий заголовок: `X-Owner: {uuid}`
- Всі запити зберігаються в БД

**Приклад:**
```bash
curl -H "X-Owner: 550e8400-e29b-41d4-a716-446655440000" \
     http://localhost:8080/api/v1/health-check
```

**Відповідь:**
```json
{"db":true,"cache":true}
```

## Тестування функціоналу

### Перевірка обов'язкового заголовка X-Owner

```bash
# Без заголовка — має бути 400
curl -s -w "\nHTTP Status: %{http_code}\n" http://localhost:8080/api/v1/health-check

# З невалідним UUID — має бути 400
curl -s -w "\nHTTP Status: %{http_code}\n" -H "X-Owner: not-a-uuid" http://localhost:8080/api/v1/health-check

# З валідним UUID — має бути 200
curl -s -w "\nHTTP Status: %{http_code}\n" -H "X-Owner: 550e8400-e29b-41d4-a716-446655440000" http://localhost:8080/api/v1/health-check
```

### Перевірка throttle (60 запитів/хвилину)

```bash
for i in {1..61}; do 
  curl -s -o /dev/null -w "%{http_code}\n" \
       -H "X-Owner: 550e8400-e29b-41d4-a716-446655440000" \
       http://localhost:8080/api/v1/health-check
done
```

Очікувано: перші 60 — 200, останній — 429

### Перевірка збереження запитів в БД

```bash
docker compose exec mysql mysql -u laravel -psecret laravel -e "SELECT id, owner_id, ip_address, status, response_code, created_at FROM health_check_logs ORDER BY id DESC LIMIT 5;"
```

## Основні команди

```bash
# Статус контейнерів
docker compose ps

# Логи
docker compose logs -f app

# Зупинити
docker compose down

# Перезапустити
docker compose restart

# Міграції
docker compose exec app php artisan migrate

# Доступ до контейнера
docker compose exec app bash
```

## Конфігурація

Налаштування в `.env.example`:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PORT=6379
```

## Структура

- **app** - Laravel 12 + PHP 8.4
- **nginx** - Веб-сервер (порт 8080)
- **mysql** - База даних MySQL 8.0
- **redis** - Кеш та черги

## Вирішення проблем

```bash
# Перегляд логів
docker compose logs --tail=100 app

# Повна перебудова
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## Ліцензія

MIT

