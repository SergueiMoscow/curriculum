# Этап сборки
FROM klakegg/hugo:0.107.0-ext-ubuntu AS builder

# Копируем исходный код
WORKDIR /src
COPY . .

# Собираем сайт (Hugo будет использовать конфиг по умолчанию)
RUN hugo --minify

# Финальный образ
FROM nginx:alpine

# Копируем собранный сайт из этапа builder
COPY --from=builder /src/public /usr/share/nginx/html

# Копируем конфиг nginx (если нужно)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Команда для запуска nginx
CMD ["nginx", "-g", "daemon off;"]