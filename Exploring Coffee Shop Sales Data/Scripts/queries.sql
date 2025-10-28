/*
===================================================================================
Script for Analyzing Coffee Shop Dataset
===================================================================================
1. Contains analytical queries on city demographics, customer behavior, and sales.
2. Answers business questions related to coffee consumption, revenue, product trends,
   customer engagement, and city-level performance.
3. Uses CTEs, subqueries, aggregation, filtering, window functions, and conditional logic.
===================================================================================
*/

-- ============================================================
-- Task 1: Estimate Coffee Consumers by City
-- Objective: Calculate 25% of each city's population as coffee consumers.
-- ============================================================
SELECT
    city_id,
    city_name,
    population,
    CAST(population * 0.25 AS INT) AS estimated_coffee_consumers
FROM dbo.city;
GO

-- ============================================================
-- Task 2: Total Revenue in Q4 2023
-- Objective: Sum coffee sales from October to December 2023.
-- ============================================================
SELECT 
    SUM(total) AS total_revenue_Q4_2023
FROM dbo.sales
WHERE sale_date >= '2023-10-01' AND sale_date <= '2023-12-31';
GO
-- ============================================================
-- Task 3: Coffee Product Sales Volume
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

-- ============================================================
-- Task 4: Average Sales Per Customer by City
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

-- ============================================================
-- Task 5: City Population and Customer Count
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

-- ============================================================
-- Task 6: Top 3 Selling Products by City
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

USE coffee_shop;
GO

-- ============================================================
-- Task 7: Unique Customers by City
-- Objective: Count distinct customers per city.
-- ============================================================
SELECT
    ci.city_name,
    COUNT(DISTINCT cu.customer_id) AS total_customers
FROM dbo.city AS ci
INNER JOIN dbo.customers AS cu ON ci.city_id = cu.city_id
GROUP BY ci.city_name;
GO

-- ============================================================
-- Task 8: Average Sale and Rent Per Customer
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

-- ============================================================
-- Task 9: Monthly Sales Growth Rate
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

-- ============================================================
-- Task 10: Top Cities by Revenue and Savings
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

-- Rank cities by net savings
SELECT TOP (5) *,
    ROUND(((total_revenue - total_rent) / total_revenue) * 100, 2) AS perc_savings,
    CAST(total_customers AS FLOAT) / 0.25 AS customer_retention 
FROM dbo.#midsales
ORDER BY perc_savings DESC;
GO

-- Objective: Rank cities by total revenue
SELECT TOP (5) *,
    ROUND(((total_revenue - total_rent) / total_revenue) * 100, 2) AS perc_savings,
    CAST(total_customers AS FLOAT) / 0.25 AS customer_retention 
FROM dbo.#midsales
ORDER BY total_revenue DESC;
GO
