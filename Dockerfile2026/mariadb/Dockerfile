FROM mariadb:11.4

COPY my.cnf /etc/mysql/conf.d/project.cnf
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 3306
