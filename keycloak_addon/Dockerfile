ARG BUILD_FROM=quay.io/keycloak/keycloak:22.0.5
FROM ${BUILD_FROM}

# Создаем директорию для провайдеров и устанавливаем драйвер MariaDB
USER root
RUN mkdir -p /opt/keycloak/providers && \
    curl -L -o /opt/keycloak/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.4/mariadb-java-client-3.5.4.jar

# Устанавливаем необходимые утилиты
RUN microdnf update -y && \
    microdnf install -y nc jq shadow-utils && \
    microdnf clean all

# Создаем том для данных и меняем владельца
RUN mkdir /data && chown keycloak:keycloak /data
VOLUME /data

USER keycloak

# Копируем скрипты
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

CMD ["/run.sh"]