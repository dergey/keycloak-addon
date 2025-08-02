ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Устанавливаем зависимости
RUN apk add --no-cache openjdk17 python3 py3-pip bash curl

# Качаем Keycloak
ENV KC_VERSION=24.0.1
RUN curl -L -o /tmp/keycloak.tar.gz https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/keycloak-${KC_VERSION}.tar.gz && \
    mkdir -p /opt/keycloak && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt/keycloak --strip-components=1 && \
    rm /tmp/keycloak.tar.gz

# Качаем MariaDB драйвер
RUN mkdir -p /opt/keycloak/providers && \
    curl -L -o /opt/keycloak/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Копируем скрипт запуска
COPY run.sh /run.sh
RUN chmod a+x /run.sh

WORKDIR /opt/keycloak

CMD [ "/run.sh" ]