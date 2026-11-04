IF DB_ID('DevOpsDB') IS NULL
    CREATE DATABASE DevOpsDB;
GO

USE DevOpsDB;
GO

IF OBJECT_ID('dbo.app_health', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.app_health (
        id INT IDENTITY(1,1) PRIMARY KEY,
        status VARCHAR(50) NOT NULL,
        created_at DATETIME2 DEFAULT SYSDATETIME()
    );
END;
GO

INSERT INTO dbo.app_health (status)
VALUES ('MSSQL initialized');
GO
