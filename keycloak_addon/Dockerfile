ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM} AS builder

RUN apk add --no-cache \
    curl \
    jq \
    netcat-openbsd \
    shadow

RUN mkdir -p /opt/providers && \
    curl -L -o /opt/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.1.4/mariadb-java-client-3.1.4.jar

FROM quay.io/keycloak/keycloak:22.0.5

COPY --from=builder /opt/providers/mariadb-java-client.jar /opt/keycloak/providers/
COPY --from=builder /usr/bin/nc /usr/bin/nc
COPY --from=builder /usr/bin/jq /usr/bin/jq

USER root
RUN mkdir /data && chown keycloak:keycloak /data
VOLUME /data

USER keycloak
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

CMD ["/run.sh"]