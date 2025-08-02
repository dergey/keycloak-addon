### Keycloak Addon for Home Assistant
**Integrate Keycloak Identity Management with Home Assistant using built-in MariaDB**

---

## 🚀 Features
- Full Keycloak identity provider integrated with Home Assistant
- Uses Home Assistant's built-in MariaDB database
- Automatic SSL configuration
- OAuth2 authentication for Home Assistant users
- Backup/restore support via Home Assistant snapshots

---

## 📦 Installation
1. Create addon directory:
   ```bash
   cd /config/addons
   mkdir keycloak
   ```
2. Create the following files in `/config/addons/keycloak`:
   - [`Dockerfile`](#dockerfile)
   - [`config.json`](#configjson)
   - [`run.sh`](#runsh)

---

## ⚙️ Configuration Files

### <a name="dockerfile"></a>`Dockerfile`
```dockerfile
ARG BUILD_FROM=quay.io/keycloak/keycloak:22.0.5
FROM ${BUILD_FROM}

# Install MariaDB driver and tools
USER root
RUN curl -L -o /opt/keycloak/providers/mariadb-java-client.jar \
    https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.1.4/mariadb-java-client-3.1.4.jar
RUN microdnf install -y nc jq
USER keycloak

# Copy launch script
COPY run.sh /run.sh
RUN chmod +x /run.sh

VOLUME /data
EXPOSE 8080

CMD ["/run.sh"]
```

### <a name="configjson"></a>`config.json`
```json
{
  "name": "Keycloak",
  "version": "22.0.5",
  "slug": "keycloak",
  "description": "Keycloak Identity Provider with MariaDB integration",
  "arch": ["amd64", "armv7", "aarch64"],
  "startup": "application",
  "boot": "auto",
  "ports": {
    "8080/tcp": 8080
  },
  "ports_description": {
    "8080/tcp": "Keycloak web interface"
  },
  "options": {
    "KEYCLOAK_ADMIN": "admin",
    "KEYCLOAK_ADMIN_PASSWORD": "changeme",
    "KC_HOSTNAME": "homeassistant.local",
    "DB_VENDOR": "mariadb",
    "DB_ADDR": "core-mariadb",
    "DB_PORT": 3306,
    "DB_DATABASE": "keycloak",
    "DB_USER": "keycloak",
    "DB_PASSWORD": "your_secure_password"
  },
  "schema": {
    "KEYCLOAK_ADMIN": "str",
    "KEYCLOAK_ADMIN_PASSWORD": "str",
    "KC_HOSTNAME": "str",
    "DB_VENDOR": "list(mysql|postgres|mariadb)",
    "DB_ADDR": "str",
    "DB_PORT": "int",
    "DB_DATABASE": "str",
    "DB_USER": "str",
    "DB_PASSWORD": "str"
  },
  "map": ["ssl"],
  "backup": {
    "database": true,
    "userfiles": ["/data"]
  },
  "init": false
}
```

### <a name="runsh"></a>`run.sh`
```bash
#!/bin/sh

# Apply Home Assistant settings
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
export KC_HOSTNAME="${KC_HOSTNAME}"

# Database configuration
export KC_DB_URL="jdbc:mariadb://${DB_ADDR}:${DB_PORT}/${DB_DATABASE}"
export KC_DB_USERNAME="${DB_USER}"
export KC_DB_PASSWORD="${DB_PASSWORD}"

# Wait for MariaDB
echo "Waiting for MariaDB at ${DB_ADDR}:${DB_PORT}..."
while ! nc -z ${DB_ADDR} ${DB_PORT}; do
  sleep 1
done
echo "MariaDB available!"

# Start Keycloak
exec /opt/keycloak/bin/kc.sh start \
  --proxy=edge \
  --hostname-strict=false \
  --http-relative-path=/auth \
  --db=mariadb \
  --db-url="${KC_DB_URL}" \
  --db-username="${KC_DB_USERNAME}" \
  --db-password="${KC_DB_PASSWORD}" \
  --features=token-exchange
```

---

## 🔧 MariaDB Setup
Add this to your MariaDB addon configuration:
```yaml
databases:
  - keycloak
rights:
  - username: keycloak
    password: your_secure_password
    database: keycloak
```

---

## 🌐 Reverse Proxy Setup
Add to `configuration.yaml`:
```yaml
http:
  reverse_proxy:
    - url: "http://keycloak:8080"
      prefix: "/auth/"
```
Access Keycloak at: `https://your-ha-domain/auth`

---

## 🔐 Home Assistant Authentication
1. Create Keycloak client:
   - Redirect URI: `https://your-ha-domain/auth/external/callback`
   - Client ID: `home-assistant`
2. Add to `configuration.yaml`:
```yaml
homeassistant:
  auth_providers:
    - type: oauth2
      name: Keycloak
      client_id: home-assistant
      client_secret: YOUR_CLIENT_SECRET
      authorize_url: https://your-ha-domain/auth/realms/master/protocol/openid-connect/auth
      token_url: https://your-ha-domain/auth/realms/master/protocol/openid-connect/token
      userinfo_url: https://your-ha-domain/auth/realms/master/protocol/openid-connect/userinfo
```

---

## ⚠️ Important Notes
1. **First Run**: Initial startup may take 2-5 minutes while creating database schema
2. **Memory Requirements**: Minimum 1GB RAM allocated to Home Assistant
3. **Admin Credentials**: Change default admin password immediately
4. **Backups**: Included in Home Assistant snapshots
5. **Updates**: Change version in both `Dockerfile` and `config.json`

---

## 🔍 Troubleshooting
Check logs via:
```bash
ha addon logs keycloak
```

Common issues:
- **DB Connection Errors**: Verify MariaDB credentials and database creation
- **Startup Timeouts**: Increase wait time in `run.sh` if using low-power hardware
- **SSL Errors**: Ensure valid certificates in `/ssl` directory

---

## 📜 License
Apache 2.0 - Same as Keycloak base image

---

> **Note**: This addon requires Home Assistant Core 2023.8 or newer. For ARM devices, add `"image": "quay.io/keycloak/keycloak:{arch}-22.0.5"` to `config.json`