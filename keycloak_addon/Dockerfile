# Этап 1: скачиваем JDBC-драйвер MariaDB
FROM alpine:3.20 AS downloader

RUN apk add --no-cache curl \
 && mkdir -p /opt/providers \
 && curl -L -o /opt/providers/mariadb-java-client.jar \
      https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Этап 2: официальный Keycloak образ
FROM quay.io/keycloak/keycloak:24.0.1

# Копируем драйвер MariaDB
COPY --from=downloader /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/

# Копируем скрипт запуска
COPY run.sh /run.sh
RUN chmod +x /run.sh

USER keycloak
ENTRYPOINT ["/run.sh"]
EXPOSE 8080
