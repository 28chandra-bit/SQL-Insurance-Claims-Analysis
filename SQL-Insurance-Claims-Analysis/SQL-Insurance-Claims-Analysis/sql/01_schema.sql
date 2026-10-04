-- SQL Insurance Claims Analysis
-- MySQL 8.0+
-- Synthetic portfolio dataset; no real customer information.

CREATE DATABASE IF NOT EXISTS insurance_claims_db;
USE insurance_claims_db;

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS policies;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    gender VARCHAR(20),
    date_of_birth DATE,
    state CHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    policy_number VARCHAR(30) NOT NULL UNIQUE,
    policy_type VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    policy_status VARCHAR(20) NOT NULL,
    annual_premium DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT NOT NULL,
    customer_id INT NOT NULL,
    claim_number VARCHAR(30) NOT NULL UNIQUE,
    claim_date DATE NOT NULL,
    claim_type VARCHAR(40) NOT NULL,
    claim_status VARCHAR(30) NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    settled_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    claim_id INT NOT NULL,
    payment_reference VARCHAR(30) NOT NULL UNIQUE,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);
