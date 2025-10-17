# Retail Sales Analysis

## Project Overview

The project involves setting up a retail sales database, cleaning and standardizing data within it, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries using SQL Server.

## Objectives

1. **Set up a retail sales database and populate it with the provided sales data.**
2. **Identify and remove records with missing or null values.**
3. **Perform basic exploratory data analysis to understand dataset shape and distributions.**
4. **Use SQL queries to answer business questions and derive actionable insights.**

## Project Structure

### 1. Database Setup

- **Database creation:** Create a database named `p1_retail_db`.
- **Table creation:** Create a table named `retail_sales` to store the sales data. The table includes columns for transaction id, sale date, sale time, customer id, gender, age, product category, quantity, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
-- Create database and switch to it
CREATE DATABASE p1_retail_db;
GO

USE p1_retail_db;
GO

-- Table definition for SQL Server.
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date       DATE,
    sale_time       TIME(0),
    customer_id     INT,
    gender          VARCHAR(10),
    age             INT,
    category        VARCHAR(35),
    quantity        INT,
    price_per_unit  DECIMAL(10,2),
    cogs            DECIMAL(10,2),
    total_sale      DECIMAL(18,2)    
);
```

### 2. Data Exploration & Cleaning

- **Record count:** Determine total number of records.
- **Customer count:** Determine number of unique customers.
- **Category list:** Identify distinct product categories.
- **Null/empty check:** Review rows with missing values and remove them after review.

```sql
-- Total number of records
SELECT COUNT(*) AS total_records
FROM retail_sales;

-- Number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- List of distinct categories
SELECT DISTINCT category
FROM retail_sales
ORDER BY category;
```

```sql
-- Check for nulls and empty strings (review before deleting)
SELECT *
FROM retail_sales
WHERE
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL OR LTRIM(RTRIM(gender)) = ''
    OR age IS NULL
    OR category IS NULL OR LTRIM(RTRIM(category)) = ''
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL;

-- Preview how many rows would be removed
SELECT COUNT(*) AS rows_to_delete
FROM retail_sales
WHERE
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL OR LTRIM(RTRIM(gender)) = ''
    OR age IS NULL
    OR category IS NULL OR LTRIM(RTRIM(category)) = ''
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL;

-- If acceptable, delete inside a transaction
BEGIN TRANSACTION;

DELETE FROM retail_sales
WHERE
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL OR LTRIM(RTRIM(gender)) = ''
    OR age IS NULL
    OR category IS NULL OR LTRIM(RTRIM(category)) = ''
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL;

-- Verify the results and COMMIT or ROLLBACK
COMMIT TRANSACTION;
```

### 3. Data Analysis & Findings

The following SQL queries answer specific business questions:

1. **Retrieve all columns for sales made on '2022-11-05':**

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in Nov-2022:**

```sql
-- Use a half-open date range for robustness
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND sale_date >= '2022-11-01' AND sale_date < '2022-12-01'
  AND quantity > 4;
```

3. **Calculate the total sales (total_sale) for each category:**

```sql
SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```

4. **Find average age of customers who purchased items from the 'Beauty' category:**

```sql
SELECT ROUND(AVG(CAST(age AS FLOAT)), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

5. **Find all transactions where the total_sale is greater than 1000:**

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;
```

6. **Find the total number of transactions (transactions_id) made by each gender in each category:**

```sql
SELECT
    category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:**

```sql
WITH monthly_avg AS (
    SELECT
        DATEPART(YEAR, sale_date)  AS year,
        DATEPART(MONTH, sale_date) AS month,
        AVG(total_sale)            AS avg_sale
    FROM retail_sales
    GROUP BY DATEPART(YEAR, sale_date), DATEPART(MONTH, sale_date)
)
SELECT year, month, avg_sale
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY year ORDER BY avg_sale DESC) AS rnk
    FROM monthly_avg
) t
WHERE rnk = 1
ORDER BY year;
```

8. **Find the top 5 customers based on the highest total sales:**

```sql
SELECT TOP (5)
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC;
```

9. **Find the number of unique customers who purchased items from each category:**

```sql
SELECT
    category,
    COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail_sales
GROUP BY category
ORDER BY cnt_unique_cs DESC;
```

10. **Write a SQL query to create each shift and number of orders (Example morning <12, afternoon between 12 & 17, evening >17):**

```sql
WITH hourly_sale AS (
    SELECT *,
           CASE
               WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
               WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
               ELSE 'Evening'
           END AS shift,
           CASE
               WHEN DATEPART(HOUR, sale_time) < 12 THEN 1
               WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 2
               ELSE 3
           END AS shift_order
    FROM retail_sales
)
SELECT shift,
       COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift, shift_order
ORDER BY shift_order;
```

## Findings

- **Customer demographics:** Customers are distributed across multiple age groups. Use avg_age and further segmentation to refine marketing targets.
- **High-value transactions:** Transactions with total_sale > 1000 exist and should be analyzed for product mix and potential fraud or VIP classification.
- **Sales trends:** Monthly average sale analysis surfaces seasonality and peak months per year.
- **Customer insights:** Top customers and unique-customer-per-category metrics support loyalty and retention strategies.
