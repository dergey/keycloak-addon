#!/bin/bash

# Вывод всех переменных окружения для отладки
echo "===== Environment Variables ====="
printenv
echo "================================="

# Проверка обязательных переменных
if [ -z "${DB_HOST}" ] || [ -z "${DB_PORT}" ] || [ -z "${DB_NAME}" ] || [ -z "${DB_PASSWORD}" ]; then
    echo "ERROR: Database configuration is incomplete!"
    echo "DB_HOST=${DB_HOST}, DB_PORT=${DB_PORT}, DB_NAME=${DB_NAME}, DB_PASSWORD=${DB_PASSWORD}"
    exit 1
fi

# Проверка наличия драйвера MariaDB
if [ ! -f /opt/keycloak/providers/mariadb-java-client.jar ]; then
    echo "ERROR: MariaDB driver not found in /opt/keycloak/providers/"
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

# Функция для проверки доступности порта с использованием встроенных средств
wait_for_db() {
    local host=$1 port=$2 timeout=60
    local start_time=$(date +%s)

    echo "Waiting for MariaDB at $host:$port..."
    while :; do
        # Используем встроенную возможность Bash для проверки порта
        if timeout 1 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
            echo "MariaDB available!"
            return 0
        fi

        local current_time=$(date +%s)
        if (( current_time - start_time > timeout )); then
            echo "ERROR: Timeout waiting for MariaDB!"
            return 1
        fi

        sleep 1
    done
}

# Ожидание доступности MariaDB
wait_for_db "${DB_ADDR}" "${DB_PORT}" || exit 1

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