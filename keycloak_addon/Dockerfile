# Этап 1: Используем базовый образ Home Assistant
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM} AS builder

RUN apk add --no-cache curl

# Скачиваем драйвер MariaDB
RUN mkdir -p /opt/providers && \
    curl -L -o /opt/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Этап 2: Используем официальный образ Keycloak
FROM quay.io/keycloak/keycloak:22.0.5

# Устанавливаем netcat непосредственно в образ Keycloak
USER root
RUN microdnf update -y && \
    microdnf install -y nc && \
    microdnf clean all

# Копируем драйвер MariaDB
COPY --from=builder /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/

# Настраиваем рабочую среду
RUN mkdir /data && chown keycloak:keycloak /data
VOLUME /data

# Копируем и настраиваем скрипт запуска
COPY run.sh /run.sh
RUN chmod +x /run.sh && chown keycloak:keycloak /run.sh

# Переопределяем точку входа
ENTRYPOINT ["/run.sh"]

USER keycloak
EXPOSE 8080