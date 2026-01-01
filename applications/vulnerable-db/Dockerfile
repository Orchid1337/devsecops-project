FROM postgres:9.6
ENV POSTGRES_PASSWORD=insecure123
ENV POSTGRES_USER=admin
ENV POSTGRES_DB=vulnerable_db
COPY init.sql /docker-entrypoint-initdb.d/
