# Этап сборки с установкой нужной версии Hugo
FROM ubuntu:22.04 AS builder

# Устанавливаем зависимости и Hugo
RUN apt-get update && apt-get install -y \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и устанавливаем Hugo Extended
ARG HUGO_VERSION=0.147.3
RUN wget -O hugo.deb "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" \
    && dpkg -i hugo.deb \
    && rm hugo.deb

# Копируем исходный код
WORKDIR /src
COPY . .

# Собираем сайт
RUN hugo --minify --source /src

# Финальный образ с Nginx
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]