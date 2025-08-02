# Этап 1: Используем базовый образ Home Assistant для начальной настройки
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM} AS builder

# Установка необходимых инструментов в базовый образ HA
RUN apk add --no-cache \
    curl \
    jq \
    netcat-openbsd \
    shadow

# Скачиваем драйвер MariaDB (используем последнюю версию)
RUN mkdir -p /opt/providers && \
    curl -L -o /opt/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Этап 2: Используем официальный образ Keycloak
FROM quay.io/keycloak/keycloak:22.0.5

# Копируем драйвер и утилиты из первого этапа
COPY --from=builder /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/
COPY --from=builder /usr/bin/nc /usr/bin/nc
COPY --from=builder /usr/bin/jq /usr/bin/jq

# Настраиваем рабочую среду
USER root
RUN mkdir /data && chown keycloak:keycloak /data
VOLUME /data

# Копируем и настраиваем скрипт запуска
COPY run.sh /run.sh
RUN chmod +x /run.sh && chown keycloak:keycloak /run.sh

# Переопределяем точку входа
ENTRYPOINT ["/run.sh"]

# Переключаемся на пользователя keycloak
USER keycloak

EXPOSE 8080