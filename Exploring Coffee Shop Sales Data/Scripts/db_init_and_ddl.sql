/*
===================================================================================
Sript for creating the database and neccessary tables for coffee shop sales data
====================================================================================
*/ 

-- ==========================================
-- Create the database
-- ==========================================
CREATE DATABASE coffee_shop;
GO

-- ==========================================
-- Use database
-- ==========================================
USE coffee_shop;
GO

-- ==========================================
-- Drop Table if Exists: city
-- ==========================================
IF OBJECT_ID('dbo.city', 'U') IS NOT NULL
    DROP TABLE dbo.city;
GO

-- ==========================================
-- Create Table: city
-- ==========================================
CREATE TABLE dbo.city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(15),
    population BIGINT,
    estimated_rent FLOAT,
    city_rank INT
);
GO

-- ==========================================
-- Drop Table if Exists: customers
-- ==========================================
IF OBJECT_ID('dbo.customers', 'U') IS NOT NULL
    DROP TABLE dbo.customers;
GO

-- ==========================================
-- Create Table: customers
-- ==========================================
CREATE TABLE dbo.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25),
    city_id INT,
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES dbo.city(city_id)
);
GO

-- ==========================================
-- Drop Table if Exists: products
-- ==========================================
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL
    DROP TABLE dbo.products;
GO

-- ==========================================
-- Create Table: products
-- ==========================================
CREATE TABLE dbo.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(35),
    price FLOAT
);
GO

-- ==========================================
-- Drop Table if Exists: sales
-- ==========================================
IF OBJECT_ID('dbo.sales', 'U') IS NOT NULL
    DROP TABLE dbo.sales;
GO

-- ==========================================
-- Create Table: sales
-- ==========================================
CREATE TABLE dbo.sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    product_id INT,
    customer_id INT,
    total FLOAT,
    rating INT,
    CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES dbo.products(product_id),
    CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
);
GO