FROM postgres:17

LABEL maintainer="hamiedreza Asosheh"
LABEL description="Custom PostgreSQL image for DevOps project"
LABEL version="1.0"

ENV TZ=UTC

COPY postgresql.conf /etc/postgresql/postgresql.conf

EXPOSE 5432

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

