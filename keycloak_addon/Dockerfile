# Stage 1: Home Assistant add-on helpers
FROM ghcr.io/home-assistant/amd64-base:latest AS base

# Stage 2: download MariaDB driver
FROM alpine:3.20 AS downloader
RUN apk add --no-cache curl \
 && mkdir -p /opt/providers \
 && curl -L -o /opt/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.2/mariadb-java-client-3.3.2.jar

# Stage 3: assemble final image
FROM quay.io/keycloak/keycloak:24.0.1

# Switch to root to copy files
USER root

# Copy helper scripts from HA base
COPY --from=base /usr/bin/with-contenv /usr/bin/with-contenv
COPY --from=base /usr/bin/bashio /usr/bin/bashio
COPY --from=base /usr/lib/python3.*/site-packages/bashio /usr/lib/python3.*/site-packages/bashio

# Copy MariaDB JDBC driver
COPY --from=downloader /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/

# Copy run script
COPY run.sh /run.sh

# Set permissions
RUN chmod +x /run.sh \
    && chown keycloak:keycloak /run.sh \
    && chown keycloak:keycloak /opt/keycloak/providers/mariadb-java-client.jar

# Entrypoint and expose port
ENTRYPOINT ["/run.sh"]

# Switch back to keycloak user
USER keycloak

EXPOSE 8080