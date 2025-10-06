ARG BUILD_FROM
FROM $BUILD_FROM

# Copy root filesystem
COPY rootfs /

RUN chmod +x /etc/services.d/vikunja_addon/finish

# Устанавливаем Vikunja (официальный образ как источник)
# Можно пойти двумя путями:
# 1) Прямо использовать vikunja/vikunja как базовый (но лучше унифицировать с базовым образом add-on)
# 2) Скопировать бинарь и статику из vikunja/vikunja
# Для простоты — запускаем vikunja/vikunja внутри базового образа через Docker-in-Docker нам не подходит.
# Поэтому используем официальный бинарь из релизов или curl; здесь — вариант с apk и wget.

# Установим необходимые инструменты
RUN apk add --no-cache unzip curl bash tzdata

# Получаем последнюю стабильную сборку Vikunja (можно зафиксировать версию)
# Пример: скачивание готового tar.gz с сервером и фронтом; при необходимости адаптируй версию.
# Ниже — placeholder; в реальном проекте лучше зафиксировать конкретную версию.
RUN mkdir -p /opt/vikunja \
 && curl -L https://dl.vikunja.io/vikunja/0.24.6/vikunja-v0.24.6-linux-amd64-full.zip -o /tmp/vikunja.zip \
 && unzip /tmp/vikunja.zip -d /opt/vikunja \
 && rm /tmp/vikunja.zip \
 && mv /opt/vikunja/vikunja-v0.24.6-linux-amd64 /opt/vikunja/vikunja \
 && chmod +x /opt/vikunja/vikunja

# Ensure all run scripts are executable
RUN find /etc/services.d/ -name 'run' -exec chmod +x {} \;
