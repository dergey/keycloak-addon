#!/bin/sh

# Применяем настройки из Home Assistant
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
export KC_HOSTNAME="${KC_HOSTNAME}"

# Параметры подключения к MariaDB
export KC_DB_URL="jdbc:mariadb://${DB_ADDR}:${DB_PORT}/${DB_DATABASE}"
export KC_DB_USERNAME="${DB_USER}"
export KC_DB_PASSWORD="${DB_PASSWORD}"

# Ожидание доступности MariaDB (важно для автоматического запуска)
echo "Ожидание запуска MariaDB на ${DB_ADDR}:${DB_PORT}..."
while ! nc -z ${DB_ADDR} ${DB_PORT}; do
  sleep 1
done
echo "MariaDB запущена!"

# Инициализация базы при первом запуске (опционально)
if [ ! -f /data/.db_initialized ]; then
  touch /data/.db_initialized
  /opt/keycloak/bin/kc.sh build \
    --db=${DB_VENDOR} \
    --db-url=${KC_DB_URL} \
    --db-username=${KC_DB_USERNAME} \
    --db-password=${KC_DB_PASSWORD}
fi

# Основной запуск Keycloak
exec /opt/keycloak/bin/kc.sh start \
  --proxy=edge \
  --hostname-strict=false \
  --http-relative-path=/auth \
  --db=${DB_VENDOR} \
  --db-url=${KC_DB_URL} \
  --db-username=${KC_DB_USERNAME} \
  --db-password=${KC_DB_PASSWORD}