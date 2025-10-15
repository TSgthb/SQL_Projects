/*
/* 
Data Cleaning
=============
*/

-- Checking the total number of rows in the dataset
SELECT COUNT(*) AS total_rows FROM retail_sales

-- Checking all the records for a overview of a dataset
SELECT * FROM retail_sales

-- Checking NULL values in a column
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL 
	  OR
	  sale_date IS NULL
	  OR 
	  sale_time IS NULL
	  OR
	  customer_id IS NULL
	  OR
	  gender IS NULL
	  OR
	  age IS NULL
	  OR
	  category IS NULL
	  OR
	  quantiy IS NULL
	  OR
	  price_per_unit IS NULL
	  OR
	  cogs IS NULL
	  OR
	  total_sale IS NULL

-- Deleting NULL values since these are non essential in the current context
DELETE
FROM retail_sales
WHERE (
	  transactions_id IS NULL 
	  OR
	  sale_date IS NULL
	  OR 
	  sale_time IS NULL
	  OR
	  customer_id IS NULL
	  OR
	  gender IS NULL
	  OR
	  age IS NULL
	  OR
	  category IS NULL
	  OR
	  quantiy IS NULL
	  OR
	  price_per_unit IS NULL
	  OR
	  cogs IS NULL
	  OR
	  total_sale IS NULL
	  )

-- Standardizing the 'cogs' column by getting to know the maximum value of the column
SELECT MAX(cogs) FROM retail_sales --620

-- Modifying the datatype of the column to store the results in a decimal format with fixed precision digits
ALTER TABLE retail_sales
ALTER COLUMN cogs DECIMAL(10,2)

-- Similarly, we will also standardize the data types for 'price_per_unit' and 'total_sale' columns
ALTER TABLE retail_sales
ALTER COLUMN price_per_unit DECIMAL(10,2)

ALTER TABLE retail_sales
ALTER COLUMN total_sale DECIMAL(10,2)


/* 
Data Exploration
================
*/

-- Q1. How many total number of sales do we have?
SELECT COUNT(*) AS total_number_of_sales 
FROM retail_sales

-- Q2. How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
FROM retail_sales

-- Q3. How many categories do we have?
SELECT COUNT(DISTINCT category) AS total_categories
FROM retail_sales
*/

/* 
Data Analysis & Business Insights 
=================================
*/

-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05'

-- Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
	  (sale_date >= '2022-11-01' AND sale_date < '2022-12-01')
	  AND
	  category = 'Clothing'
	  AND
	  quantiy >= 4

-- Q3. Write a SQL query to calculate the total sales (total_sale) for each category
SELECT category,
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category

-- Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category
SELECT AVG(age) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
SELECT gender,
	   category,
	   COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY gender,
		 category
ORDER BY gender,
		 category

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Using CTEs
WITH monthly_avg_sales AS
(
	SELECT 
		YEAR(sale_date) as year_name,
		DATENAME(month,sale_date) as month_name,
		MONTH(sale_date) as month_number,
		AVG(total_sale) as avg_sales  	
	FROM retail_sales
	GROUP BY
		YEAR(sale_date),
		DATENAME(month,sale_date),
		MONTH(sale_date)
	--ORDER BY
	--	year_name,
	--	month_number
)
SELECT *
FROM monthly_avg_sales AS mas
WHERE avg_sales = (
					SELECT MAX(avg_sales)
					FROM monthly_avg_sales
					WHERE year_name = mas.year_name
				  )
ORDER BY 
	year_name,
	month_name
/*
-- Using RANK and PARTITION functions
SELECT
	year_name,
	month_name,
	avg_sales
FROM
	(
		SELECT 
			YEAR(sale_date) AS year_name,
			DATENAME(month,sale_date) AS month_name,
			AVG(total_sale) as avg_sales,
			RANK() OVER(
						PARTITION BY YEAR(sale_date) 
						ORDER BY AVG(total_sale) DESC
					   ) AS ranking
		FROM 
			retail_sales
		GROUP BY
			YEAR(sale_date),
			DATENAME(month,sale_date)
	) AS ranked_months_per_year
WHERE
	ranking = 1
*/

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT TOP 5 
	customer_id, 
	SUM(total_sale) AS total_sales
FROM retail_sales 
GROUP BY customer_id
ORDER BY total_sales DESC

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS number_of_unique_customers
FROM
	retail_sales
GROUP BY 
	category

-- Q10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH shifts AS
(
	SELECT 
		CASE 
			WHEN sale_time > '00:00:00' AND sale_time < '12:00:00' THEN 'Morning'
			WHEN sale_time >= '12:00:00' AND sale_time <= '17:00:00' THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift_type
	FROM retail_sales
) 
SELECT 
	shift_type,
	COUNT(*) AS shift_counts
FROM shifts
GROUP BY shift_type
ORDER BY
	CASE shift_type
		WHEN 'Morning' THEN 1
		WHEN 'Afternoon' THEN 2
		WHEN 'Evening' THEN 3
	END

