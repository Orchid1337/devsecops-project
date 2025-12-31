FROM nginx:1.18.0-alpine

# Kopiowanie konfiguracji
COPY nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html

# Ustawienie niebezpiecznych uprawnień dla demonstracji
RUN chmod 777 /var/cache/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
