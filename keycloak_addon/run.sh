#!/bin/sh

# Ожидание доступности MariaDB с таймаутом
wait_for_db() {
    local host=$1 port=$2 timeout=30
    echo "Waiting for MariaDB at ${host}:${port}..."
    while ! nc -z ${host} ${port}; do
        timeout=$((timeout-1))
        if [ $timeout -le 0 ]; then
            echo "Timeout waiting for MariaDB!"
            exit 1
        fi
        sleep 1
    done
    echo "MariaDB available!"
}

# Применяем настройки
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
export KC_HOSTNAME="${KC_HOSTNAME:-keycloak.local}"

# Проверка обязательных переменных
if [ -z "${DB_ADDR}" ] || [ -z "${DB_PORT}" ] || [ -z "${DB_DATABASE}" ]; then
    echo "Database configuration is incomplete!"
    exit 1
fi

# Ожидаем доступность БД
wait_for_db "${DB_ADDR}" "${DB_PORT}"

# Формируем параметры запуска
KC_ARGS="start --auto-build \
    --proxy=edge \
    --hostname-strict=false \
    --http-relative-path=/auth \
    --db=mariadb \
    --db-url=jdbc:mariadb://${DB_ADDR}:${DB_PORT}/${DB_DATABASE} \
    --db-username=${DB_USER:-keycloak} \
    --db-password=${DB_PASSWORD} \
    --features=token-exchange"

# Добавляем опциональные параметры
[ -n "${KC_HOSTNAME}" ] && KC_ARGS="${KC_ARGS} --hostname=${KC_HOSTNAME}"

# Запуск Keycloak
echo "Starting Keycloak with arguments: ${KC_ARGS}"
exec /opt/keycloak/bin/kc.sh ${KC_ARGS}