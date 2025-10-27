-- 1.  How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT
	city_id,
	city_name,
	population,
	CAST(population * 0.25 AS INT) AS estimated_coffee_consumers
FROM 
	dbo.city ct
GO

-- 2.  What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT 
	SUM(total) AS total_revenue_Q4_2023
FROM
	dbo.sales
WHERE
	sale_date >= '2023-10-01' 
	AND 
	sale_date <= '2023-12-31' 
GO

-- 3.  How many units of each coffee product have been sold?

SELECT 
	sl.product_id,
	pr.product_name,
	COUNT(sl.sale_id) AS items_sold
FROM 
	dbo.sales sl
	LEFT JOIN dbo.products pr
		ON	sl.product_id = pr.product_id
WHERE 
	sl.product_id IS NOT NULL
GROUP BY
	sl.product_id,
	pr.product_name
ORDER BY
	items_sold DESC
GO

-- 4.  What is the average sales amount per customer in each city?

WITH city_cust_sales AS
(
SELECT 
	ci.city_name,
	cu.customer_id,
	SUM(sl.total) AS amount
FROM
	dbo.sales sl
	LEFT JOIN dbo.customers cu
		ON sl.customer_id = cu.customer_id
	LEFT JOIN dbo.city ci
		ON cu.city_id = ci.city_id
WHERE 
	cu.customer_id IS NOT NULL
	AND
	ci.city_id IS NOT NULL
GROUP BY
	ci.city_name,
	cu.customer_id
--ORDER BY 
--	ci.city_name,
--	cu.customer_name
)

SELECT
	ccs.city_name,
	COUNT(ccs.customer_id) AS total_customers,
	SUM(ccs.amount) AS total_sales,
	ROUND(SUM(ccs.amount) / COUNT(ccs.customer_id),2) AS per_person_average_spend,
	MAX(ccs.amount) AS highest_spend,
	MIN(ccs.amount) AS lowest_spend
FROM 
	city_cust_sales ccs
GROUP BY 
	ccs.city_name
ORDER BY per_person_average_spend DESC
GO

-- 5.  Provide a list of cities along with their populations and total customers.

SELECT 
	ci.city_name,
	ROUND(CAST(AVG(ci.population * 0.25)/1000000.00 AS FLOAT),2) AS total_coffee_drinker_population_in_millions,
	COUNT(DISTINCT cu.customer_id) AS total_customers
FROM
	dbo.city ci
	INNER JOIN dbo.customers cu
		ON ci.city_id = cu.city_id
GROUP BY 
	ci.city_name
ORDER BY
	total_coffee_drinker_population_in_millions DESC
GO

-- 6. What are the top 3 selling products in each city based on sales volume?

WITH products_rank_in_city AS
(
SELECT
	ci.city_name,
	pr.product_name,
	SUM(sl.total) AS total_sales,
	ROW_NUMBER() OVER(PARTITION BY ci.city_name ORDER BY SUM(sl.total) DESC) AS product_sales_rank
FROM
	dbo.sales sl
	LEFT JOIN dbo.products pr
		ON sl.product_id = pr.product_id
	LEFT JOIN dbo.customers cu
		ON sl.customer_id = cu.customer_id
	LEFT JOIN dbo.city ci
		ON cu.city_id = ci.city_id
WHERE
	pr.product_id IS NOT NULL
	AND
	cu.customer_id IS NOT NULL
	AND
	ci.city_id	IS NOT NULL
GROUP BY
	ci.city_name,
	pr.product_name
)
SELECT 
    *
FROM
	products_rank_in_city
WHERE
	product_sales_rank <= 3
GO

-- 7. How many unique customers are there in each city who have purchased coffee products?

SELECT
	ci.city_name,
	COUNT(DISTINCT cu.customer_id) AS total_customers
FROM dbo.city AS ci
	INNER JOIN dbo.customers AS cu
		ON city.city_id = customers.city_id
GROUP BY
	ci.city_name
GO

-- 8. Find each city and their average sale per customer and avg rent per customer

SELECT
	cu.city_name,
	ROUND(SUM(sa.total) / COUNT(DISTINCT cu.customer_id),2) AS avg_sale_amount,
	ROUND(AVG(ci.estimated_rent) / COUNT(DISTINCT cu.customer_id),2) AS avg_rent
FROM dbo.city AS ci
	INNER JOIN dbo.customers cu
		ON ci.customer_id = cu.customer_id
	INNER JOIN dbo.sales sa
		ON cu.customer_id = sa.customer_id
GROUP BY cu.city_name
GO

-- 9. Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH mom_analyze AS
(
SELECT
	SUM(total) AS curr_month_sales,
	LAG(SUM(total)) OVER(PARTITION BY DATEPART(YEAR,sale_date), DATEPART(MONTH,sale_date) sale_date ASC) AS prev_month_sales
FROM
	dbo.sales
GROUP BY 
	DATEPART(YEAR,sale_date),
	DATEPART(MONTH,sale_date)
ORDER BY 
	sale_date ASC
) 
SELECT 
	*,
	ROUND((CAST((prev_month_sales - curr_month_sales) AS FLOAT) / prev_month_sales) * 100, 1) AS mom_sales_analyze
FROM mom_analyze
GO
