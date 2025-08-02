#!/usr/bin/with-contenv bashio
# run.sh — ожидание MariaDB и запуск Keycloak

set -e
bashio::log.info "== Keycloak Add-on starting =="

# Ждём готовности MariaDB (до 60 сек)
bashio::log.info "Waiting for MariaDB service..."
bashio::services.wait_for 'core_mariadb' 60

# Читаем параметры из конфигурации аддона
export DB_ADDR=$(bashio::config 'db_host')
export DB_PORT=$(bashio::config 'db_port')
export DB_DATABASE=$(bashio::config 'db_name')
export DB_USER=$(bashio::config 'db_user')
export DB_PASSWORD=$(bashio::config 'db_password')

export KEYCLOAK_ADMIN=$(bashio::config 'KEYCLOAK_ADMIN')
export KEYCLOAK_ADMIN_PASSWORD=$(bashio::config 'KEYCLOAK_ADMIN_PASSWORD')
export KC_HOSTNAME=$(bashio::config 'KC_HOSTNAME')

bashio::log.info "DB: ${DB_ADDR}:${DB_PORT}/${DB_DATABASE}"

# Запускаем Keycloak в production-режиме с MariaDB
exec /opt/keycloak/bin/kc.sh start \
    --proxy=edge \
    --hostname-strict=false \
    \${KC_HOSTNAME:+--hostname=\$KC_HOSTNAME} \
    --http-relative-path=/auth \
    --db=mariadb \
    --db-url=jdbc:mariadb://\${DB_ADDR}:\${DB_PORT}/\${DB_DATABASE} \
    --db-username=\${DB_USER} \
    --db-password=\${DB_PASSWORD} \
    --features=token-exchange