# Этап 1: базовый образ Home Assistant Add-on
FROM ghcr.io/home-assistant/amd64-base:latest AS base

# Устанавливаем curl, python3 и bashio, скачиваем драйвер MariaDB
RUN apk add --no-cache curl python3 py3-pip \
    && pip3 install --no-cache-dir bashio \
    && mkdir -p /opt/providers \
    && curl -L -o /opt/providers/mariadb-java-client.jar \
       https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Этап 2: официальный образ Keycloak
FROM quay.io/keycloak/keycloak:24.0.1

# Копируем bashio и JDBC-драйвер
COPY --from=base /usr/local/lib/python3.*/site-packages/bashio /usr/local/lib/python3.*/site-packages/bashio
COPY --from=base /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/

# Устанавливаем права
USER root
RUN chown keycloak:keycloak /opt/keycloak/providers/mariadb-java-client.jar

# Копируем скрипт запуска
COPY run.sh /run.sh
RUN chmod +x /run.sh && chown keycloak:keycloak /run.sh

# Точка входа
ENTRYPOINT ["/run.sh"]
USER keycloak
EXPOSE 8080