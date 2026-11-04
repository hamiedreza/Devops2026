FROM mysql:8.4

LABEL maintainer="hamiedreza Asosheh"
LABEL description="Custom MySQL image for DevOps database project"
LABEL version="1.0"

ENV TZ=UTC

COPY my.cnf /etc/mysql/conf.d/custom.cnf

EXPOSE 3306

CMD ["mysqld"]
