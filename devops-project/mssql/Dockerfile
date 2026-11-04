FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

COPY --chown=mssql:root init.sql /opt/mssql-tools/init.sql

USER mssql

EXPOSE 1433
