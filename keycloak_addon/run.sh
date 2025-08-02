#!/bin/sh

# Проверка наличия драйвера MariaDB
if [ ! -f /opt/keycloak/providers/mariadb-java-client.jar ]; then
    echo "ERROR: MariaDB driver not found in /opt/keycloak/providers/"
    exit 1
fi

# Применение настроек
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-admin}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-changeme}"
export KC_HOSTNAME="${KC_HOSTNAME:-keycloak.local}"

# Ожидание доступности MariaDB
echo "Waiting for MariaDB at ${DB_ADDR}:${DB_PORT}..."
while ! nc -z "${DB_ADDR}" "${DB_PORT}"; do
    sleep 1
done
echo "MariaDB available!"

# Формируем команду запуска
CMD="/opt/keycloak/bin/kc.sh start \
    --proxy=edge \
    --hostname-strict=false \
    --http-relative-path=/auth \
    --db=mariadb \
    --db-url=\"jdbc:mariadb://${DB_ADDR}:${DB_PORT}/${DB_DATABASE}\" \
    --db-username=\"${DB_USER:-keycloak}\" \
    --db-password=\"${DB_PASSWORD}\" \
    --features=token-exchange"

# Добавляем опциональные параметры
[ -n "${KC_HOSTNAME}" ] && CMD="${CMD} --hostname=${KC_HOSTNAME}"

# Запуск Keycloak
echo "Starting Keycloak with command:"
echo "${CMD}"
eval exec ${CMD}