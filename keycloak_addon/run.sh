#!/bin/bash

# Применение настроек
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-admin}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-changeme}"
export KC_HOSTNAME="${KC_HOSTNAME:-keycloak.local}"

# Получаем параметры базы данных из сервиса Home Assistant
if [ -z "${db_host}" ]; then
    echo "Using Home Assistant service discovery for database"
    DB_HOST=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/services/mysql | jq -r '.data.host')
    DB_PORT=3306
    DB_NAME="keycloak"
    DB_USER="keycloak"
    DB_PASSWORD=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/services/mysql | jq -r '.data.password')
else
    echo "Using manual database configuration"
    DB_HOST="${db_host}"
    DB_PORT="${db_port}"
    DB_NAME="${db_name}"
    DB_USER="${db_user}"
    DB_PASSWORD="${db_password}"
fi

# Проверка обязательных переменных
if [ -z "${DB_HOST}" ] || [ -z "${DB_PORT}" ] || [ -z "${DB_NAME}" ] || [ -z "${DB_PASSWORD}" ]; then
    echo "ERROR: Database configuration is incomplete!"
    echo "DB_HOST=${DB_HOST}, DB_PORT=${DB_PORT}, DB_NAME=${DB_NAME}, DB_PASSWORD=${DB_PASSWORD}"
    exit 1
fi

# Функция для проверки доступности порта
wait_for_db() {
    local host=$1 port=$2 timeout=60
    local start_time=$(date +%s)

    echo "Waiting for MariaDB at $host:$port..."
    while :; do
        # Используем встроенную возможность Bash
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
wait_for_db "${DB_HOST}" "${DB_PORT}" || exit 1

# Запуск Keycloak
exec /opt/keycloak/bin/kc.sh start \
    --proxy=edge \
    --hostname-strict=false \
    --http-relative-path=/auth \
    --db=mariadb \
    --db-url="jdbc:mariadb://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
    --db-username="${DB_USER}" \
    --db-password="${DB_PASSWORD}" \
    --features=token-exchange