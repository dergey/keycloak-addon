ARG BUILD_FROM=quay.io/keycloak/keycloak:22.0.5
FROM ${BUILD_FROM}

# Установка драйвера MariaDB
USER root
RUN curl -L -o /opt/keycloak/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.1.4/mariadb-java-client-3.1.4.jar

# Установка утилит
RUN microdnf install -y nc jq
USER keycloak

# Копируем скрипты
COPY run.sh /run.sh
RUN chmod +x /run.sh

VOLUME /data
EXPOSE 8080

CMD ["/run.sh"]