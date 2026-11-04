CREATE TABLE IF NOT EXISTS app_health (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_health (status)
VALUES ('MariaDB initialized');
