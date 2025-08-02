# Используем базовый образ для аддонов Home Assistant
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM} AS builder

# Скачиваем драйвер MariaDB
RUN apk add --no-cache curl && \
    mkdir -p /opt/providers && \
    curl -L -o /opt/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Этап 2: Официальный образ Keycloak
FROM quay.io/keycloak/keycloak:24.0.1

# Устанавливаем необходимые зависимости для bashio
USER root
RUN microdnf update -y && \
    microdnf install -y python3 py3-pip && \
    pip3 install --no-cache-dir bashio && \
    microdnf clean all

# Копируем драйвер
COPY --from=builder /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/

# Настройка среды
RUN mkdir /data && chown keycloak:keycloak /data
VOLUME /data

# Копируем скрипт запуска
COPY run.sh /run.sh
RUN chmod a+x /run.sh && chown keycloak:keycloak /run.sh

# Точка входа
ENTRYPOINT ["/run.sh"]

USER keycloak
EXPOSE 8080