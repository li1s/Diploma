# Используем официальный образ Nginx
FROM nginx:alpine

# Копируем кастомные файлы из локальной директории
COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css

# Открываем порт 80
EXPOSE 80