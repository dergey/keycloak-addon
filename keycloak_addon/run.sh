#!/bin/bash

# Проверка наличия драйвера MariaDB
if [ ! -f /opt/keycloak/providers/mariadb-java-client.jar ]; then
    echo "ERROR: MariaDB driver not found in /opt/keycloak/providers/"
    exit 1
fi

# Проверка наличия netcat
if ! command -v nc &> /dev/null; then
    echo "ERROR: nc (netcat) is not installed!"
    exit 1
fi

# Применение настроек
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-admin}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-changeme}"
export KC_HOSTNAME="${KC_HOSTNAME:-keycloak.local}"

# Проверка обязательных переменных
if [ -z "${DB_ADDR}" ] || [ -z "${DB_PORT}" ] || [ -z "${DB_DATABASE}" ] || [ -z "${DB_PASSWORD}" ]; then
    echo "ERROR: Database configuration is incomplete!"
    echo "DB_ADDR=${DB_ADDR}, DB_PORT=${DB_PORT}, DB_DATABASE=${DB_DATABASE}, DB_PASSWORD=${DB_PASSWORD}"
    exit 1
fi

# Ожидание доступности MariaDB с таймаутом
echo "Waiting for MariaDB at ${DB_ADDR}:${DB_PORT}..."
timeout 60 bash -c "until nc -z ${DB_ADDR} ${DB_PORT}; do sleep 1; done"

if [ $? -ne 0 ]; then
    echo "ERROR: Timeout waiting for MariaDB!"
    exit 1
fi

echo "MariaDB available!"

# Запуск Keycloak
exec /opt/keycloak/bin/kc.sh start \
    --proxy=edge \
    --hostname-strict=false \
    --http-relative-path=/auth \
    --db=mariadb \
    --db-url="jdbc:mariadb://${DB_ADDR}:${DB_PORT}/${DB_DATABASE}" \
    --db-username="${DB_USER:-keycloak}" \
    --db-password="${DB_PASSWORD}" \
    --features=token-exchange