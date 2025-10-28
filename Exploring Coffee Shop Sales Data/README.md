# Exploring Coffee Shop Sales Data

## Project Overview

The project aims to showcase the analysis conducted on the sales data of a fictitious coffee store, Monday Coffee, that has been selling its products online since January 2023. Monday Coffee wants to expand their business and open stores in other parts of India as well. Hence, this project aims to help make business decisions for expansion of the stores in the potential top three major cities in India, based on consumer demand, sales performance and other relevant demographics. The critical steps involved in this project are database and schema creation, analyzing and loading data from CSV sources, performing CRUD operations and using SQL advanced queries for operational reporting and data maintenance.

## Objectives

**1. Set up a database and required tables.**
**2. Import the data in tables using external CSV files**
**3. Use SQL queries to answer business questions and derive actionable insights.**

## Project Structure

**1. Database Setup**

- **Database creation:** Create a database named `coffee_shop`.

```sql
-- ====================================
-- Create the database and switch to it
-- ====================================
CREATE DATABASE coffee_shop;
GO

USE coffee_shop;
GO
```

- **Creating required tables:** Create tables `city`, `customers`, `prodcuts` and `sales` to store the coffee store data. Foreign key columns are linked to appropriate columns to ensure that applicable data can be joined and queried.

```sql
-- =====================================================
-- Drop the city table if it exists and create a new one
-- =====================================================
IF OBJECT_ID('dbo.city', 'U') IS NOT NULL
    DROP TABLE dbo.city;
GO

CREATE TABLE dbo.city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(15),
    population BIGINT,
    estimated_rent FLOAT,
    city_rank INT
);
GO

-- ==========================================================
-- Drop the customers table if it exists and create a new one
-- ==========================================================
IF OBJECT_ID('dbo.customers', 'U') IS NOT NULL
    DROP TABLE dbo.customers;
GO

CREATE TABLE dbo.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25),
    city_id INT,
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES dbo.city(city_id)
);
GO

-- =========================================================
-- Drop the products table if it exists and create a new one
-- =========================================================
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL
    DROP TABLE dbo.products;
GO

CREATE TABLE dbo.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(35),
    price FLOAT
);
GO

-- =====================================================
-- Drop the sales table if it exists and create a new one
-- =====================================================
IF OBJECT_ID('dbo.sales', 'U') IS NOT NULL
    DROP TABLE dbo.sales;
GO

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
```

