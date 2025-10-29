/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
1. To calculate running totals or moving averages for key metrics.
2. To track performance over time cumulatively.
3. Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
1. Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per year, the running total of sales over time and moving average price of sales over time

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t
