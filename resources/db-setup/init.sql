CREATE USER 'local_user'@'%' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON MOVIE_STREAM_DB.* TO 'local_user'@'%';

FLUSH PRIVILEGES;

-- Creates a database.
CREATE DATABASE IF NOT EXISTS MOVIE_STREAM_DB;

USE MOVIE_STREAM_DB;

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    subscriptionId INT
);

-- Create subscriptions table
CREATE TABLE subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    packageName VARCHAR(255) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Create payments table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    subscriptionId INT,
    transactionDate DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO users (userName, password, email, subscriptionId) VALUES
('user1', 'password1', 'abc@dummymail.com', 1),
('user2', 'password2', 'def@dummymail.com', 2),
('user3', 'password3', 'ghi@dummymail.com', 3);

INSERT INTO subscriptions (userId, packageName, startDate, endDate, price) VALUES
(1, 'BASIC', '2024-01-01', '2024-12-31', 3.99),
(2, 'PREMIUM', '2024-01-01', '2024-12-31', 3.99),
(3, 'PREMIUM', '2024-01-01', '2024-12-31', 44.99);

INSERT INTO payments (userId, subscriptionId, transactionDate, amount) VALUES
(1, 1, '2024-07-04', 3.99),
(2, 2, '2024-07-04', 3.99),
(3, 3, '2024-07-04', 44.99);

ALTER TABLE payments
ADD CONSTRAINT chk_amount CHECK (amount >= 3.99);
