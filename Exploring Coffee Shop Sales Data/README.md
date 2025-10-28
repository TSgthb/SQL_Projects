# Exploring Coffee Shop Sales Data

## Project Overview

The project aims to showcase the analysis conducted on the sales data of a fictitious coffee store, Monday Coffee, that has been selling its products online since January 2023. Monday Coffee wants to expand their business and open stores in other parts of India as well. Hence, this project aims to help make business decisions for expansion of the stores in the potential top three major cities in India, based on consumer demand, sales performance and other relevant demographics. The critical steps involved in this project are database and schema creation, analyzing and loading data from CSV sources, performing CRUD operations and using SQL advanced queries for operational reporting and data maintenance.

## Objectives

**1. Set up a database and required tables.**
**2. Import the data in tables using external CSV files**
**3. Use SQL queries to answer business questions and derive actionable insights.**
**4. Provide recommendations for potential business expansion.**

## Project Structure

### 1. Database Setup

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

- **Creating required tables:** Create tables `city`, `customers`, `products` and `sales` to store the coffee store data. Foreign key columns are linked to appropriate columns to ensure that applicable data can be joined and queried.

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

### 2. Data Insertion

- **Bulk import:** Data will be loaded in the tables using BULK INSERT from comma delimited files. The script below uses FIRSTROW = 2 to skip headers, FIELDTERMINATOR = ',' and TABLOCK for speed.
  
```sql
-- =================================================================
-- Load the data in the tables - city, customers, products and sales
-- =================================================================
BULK INSERT dbo.city
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Coffee Shop Analysis\Sources\city.csv'
WITH
(
    FIRSTROW = 2,               -- Skip header row
    FIELDTERMINATOR = ',',      -- Comma-delimited file
    TABLOCK                     -- Optimized bulk insert
);
GO

BULK INSERT dbo.customers
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Coffee Shop Analysis\Sources\customers.csv'
WITH
(
    FIRSTROW = 2,               -- Skip header row
    FIELDTERMINATOR = ',',      -- Comma-delimited file
    TABLOCK                     -- Optimized bulk insert
);
GO

BULK INSERT dbo.products
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Coffee Shop Analysis\Sources\products.csv'
WITH
(
    FIRSTROW = 2,               -- Skip header row
    FIELDTERMINATOR = ',',      -- Comma-delimited file
    TABLOCK                     -- Optimized bulk insert
);
GO

BULK INSERT dbo.sales
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Coffee Shop Analysis\Sources\sales.csv'
WITH
(
    FIRSTROW = 2,               -- Skip header row
    FIELDTERMINATOR = ',',      -- Comma-delimited file
    TABLOCK                     -- Optimized bulk insert
);
GO
```

### 3. Data Analytics and Insights

- **The following queries answers various business questions and uncover important insights. This section queries utilizes advance SQL concepts such as CTEs, temp table, aggregations, window functions and date manipulation.**

**Task 1: Estimate Coffee Consumers by City**

```sql
-- ============================================================
-- Objective: Calculate 25% of each city's population as coffee consumers.
-- ============================================================
SELECT
    city_id,
    city_name,
    population,
    CAST(population * 0.25 AS INT) AS estimated_coffee_consumers
FROM dbo.city;
GO
```

**Task 2: Total Revenue in Q4 2023**

```sql
-- ============================================================
-- Objective: Sum coffee sales from October to December 2023.
-- ============================================================
SELECT 
    SUM(total) AS total_revenue_Q4_2023
FROM dbo.sales
WHERE sale_date >= '2023-10-01' AND sale_date <= '2023-12-31';
GO
```

**Task 3: Coffee Product Sales Volume**

```sql
-- ============================================================
-- Objective: Count units sold for each coffee product.
-- ============================================================
SELECT 
    sl.product_id,
    pr.product_name,
    COUNT(sl.sale_id) AS items_sold
FROM dbo.sales sl
LEFT JOIN dbo.products pr ON sl.product_id = pr.product_id
WHERE sl.product_id IS NOT NULL
GROUP BY sl.product_id, pr.product_name
ORDER BY items_sold DESC;
GO
```

**Task 4: Average Sales Per Customer by City**

```sql
-- ============================================================
-- Objective: Analyze customer spending patterns per city.
-- ============================================================
WITH city_cust_sales AS (
    SELECT 
        ci.city_name,
        cu.customer_id,
        SUM(sl.total) AS amount
    FROM dbo.sales sl
    LEFT JOIN dbo.customers cu ON sl.customer_id = cu.customer_id
    LEFT JOIN dbo.city ci ON cu.city_id = ci.city_id
    WHERE cu.customer_id IS NOT NULL AND ci.city_id IS NOT NULL
    GROUP BY ci.city_name, cu.customer_id
)
SELECT
    ccs.city_name,
    COUNT(ccs.customer_id) AS total_customers,
    SUM(ccs.amount) AS total_sales,
    ROUND(SUM(ccs.amount) / COUNT(ccs.customer_id), 2) AS per_person_average_spend,
    MAX(ccs.amount) AS highest_spend,
    MIN(ccs.amount) AS lowest_spend
FROM city_cust_sales ccs
GROUP BY ccs.city_name
ORDER BY per_person_average_spend DESC;
GO
```

**Task 5: City Population and Customer Count**

```sql
-- ============================================================
-- Objective: List cities with estimated coffee drinkers and customer totals.
-- ============================================================
SELECT 
    ci.city_name,
    ROUND(CAST(AVG(ci.population * 0.25) / 1000000.00 AS FLOAT), 2) AS total_coffee_drinker_population_in_millions,
    COUNT(DISTINCT cu.customer_id) AS total_customers
FROM dbo.city ci
INNER JOIN dbo.customers cu ON ci.city_id = cu.city_id
GROUP BY ci.city_name
ORDER BY total_coffee_drinker_population_in_millions DESC;
GO
```

**Task 6: Top 3 Selling Products by City**

```sql
-- ============================================================
-- Objective: Rank products by sales volume within each city.
-- ============================================================
WITH products_rank_in_city AS (
    SELECT
        ci.city_name,
        pr.product_name,
        SUM(sl.total) AS total_sales,
        ROW_NUMBER() OVER(PARTITION BY ci.city_name ORDER BY SUM(sl.total) DESC) AS product_sales_rank
    FROM dbo.sales sl
    LEFT JOIN dbo.products pr ON sl.product_id = pr.product_id
    LEFT JOIN dbo.customers cu ON sl.customer_id = cu.customer_id
    LEFT JOIN dbo.city ci ON cu.city_id = ci.city_id
    WHERE pr.product_id IS NOT NULL AND cu.customer_id IS NOT NULL AND ci.city_id IS NOT NULL
    GROUP BY ci.city_name, pr.product_name
)
SELECT *
FROM products_rank_in_city
WHERE product_sales_rank <= 3;
GO
```

**Task 7: Unique Customers by City**

```sql
-- ============================================================
-- Objective: Count distinct customers per city.
-- ============================================================
USE coffee_shop;
GO

SELECT
    ci.city_name,
    COUNT(DISTINCT cu.customer_id) AS total_customers
FROM dbo.city AS ci
INNER JOIN dbo.customers AS cu ON ci.city_id = cu.city_id
GROUP BY ci.city_name;
GO
```

**Task 8: Average Sale and Rent Per Customer**

```sql
-- ============================================================
-- Objective: Compare average sale and rent per customer across cities.
-- ============================================================
SELECT
    ci.city_name,
    ROUND(SUM(sa.total) / COUNT(DISTINCT cu.customer_id), 2) AS avg_sale_amount,
    ROUND(AVG(ci.estimated_rent) / COUNT(DISTINCT cu.customer_id), 2) AS avg_rent
FROM dbo.city AS ci
INNER JOIN dbo.customers cu ON ci.city_id = cu.city_id
INNER JOIN dbo.sales sa ON cu.customer_id = sa.customer_id
GROUP BY ci.city_name;
GO
```

**Task 9: Monthly Sales Growth Rate**

```sql
-- ============================================================
-- Objective: Calculate month-over-month percentage change in sales.
-- ============================================================
WITH month_sales AS (
    SELECT
        DATEPART(YEAR, sale_date) AS year_of_sale,
        DATEPART(MONTH, sale_date) AS month_of_sale,
        SUM(total) AS curr_month_sales
    FROM dbo.sales
    GROUP BY DATEPART(YEAR, sale_date), DATEPART(MONTH, sale_date)
),
mom_analysis AS (
    SELECT 
        year_of_sale,
        month_of_sale,
        curr_month_sales,
        LAG(curr_month_sales) OVER(PARTITION BY year_of_sale ORDER BY month_of_sale ASC) AS prev_month_sales
    FROM month_sales
)
SELECT *,
    ROUND((CAST((prev_month_sales - curr_month_sales) AS FLOAT) / prev_month_sales) * 100, 1) AS mom_sales_analyze
FROM mom_analysis;
GO
```

**Task 10: Top Cities by Revenue and Savings**

```sql
-- ============================================================
-- Objective: Identify top cities by revenue, rent, and customer metrics.
-- ============================================================
SELECT 
    ci.city_name,
    SUM(sa.total) AS total_revenue,
    ROUND(SUM(sa.total) / COUNT(DISTINCT cu.customer_id), 2) AS avg_revenue_per_person,
    MAX(ci.estimated_rent) AS total_rent,
    ROUND(MAX(ci.estimated_rent) / COUNT(DISTINCT cu.customer_id), 2) AS avg_rent_per_person,
    COUNT(DISTINCT cu.customer_id) AS total_customers,
    ROUND(CAST(MAX(ci.population) AS FLOAT) / 1000000, 2) AS [total_population(in million)],
    ROUND(CAST(MAX(ci.population) * 0.25 AS FLOAT) / 1000000, 2) AS [coffee_drinkers(in million)]
INTO #midsales
FROM dbo.city ci
INNER JOIN dbo.customers cu ON ci.city_id = cu.city_id
INNER JOIN dbo.sales sa ON cu.customer_id = sa.customer_id
GROUP BY ci.city_name;
GO

--Rank Cities by Net Savings

SELECT TOP (5) *,
    ROUND(((total_revenue - total_rent) / total_revenue) * 100, 2) AS perc_savings,
    CAST(total_customers AS FLOAT) / 0.25 AS customer_retention 
FROM dbo.#midsales
ORDER BY perc_savings DESC;
GO


--Rank Cities by Total Revenue

SELECT TOP (5) *,
    ROUND(((total_revenue - total_rent) / total_revenue) * 100, 2) AS perc_savings,
    CAST(total_customers AS FLOAT) / 0.25 AS customer_retention 
FROM dbo.#midsales
ORDER BY total_revenue DESC;
GO
```



