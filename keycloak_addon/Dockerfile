ARG BUILD_FROM
FROM $BUILD_FROM

# Copy root filesystem
COPY rootfs /

# Устанавливаем Java17, Nginx и curl
RUN apk add --no-cache openjdk17 nginx curl

# Устанавливаем Keycloak
ENV KC_VERSION=26.3.2
RUN curl -L -o /tmp/keycloak.tar.gz https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/keycloak-${KC_VERSION}.tar.gz && \
    mkdir -p /opt/keycloak && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt/keycloak --strip-components=1 && \
    rm /tmp/keycloak.tar.gz

# Устанавливаем MariaDB драйвер
RUN mkdir -p /opt/keycloak/providers && \
    curl -L -o /opt/keycloak/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.4/mariadb-java-client-3.5.4.jar

# Создаём директорию для NGINX runtime/logging
RUN mkdir -p /run/nginx
RUN mkdir -p /var/log/nginx/

# Ensure all run scripts are executable
RUN find /etc/services.d/ -name 'run' -exec chmod +x {} \;
