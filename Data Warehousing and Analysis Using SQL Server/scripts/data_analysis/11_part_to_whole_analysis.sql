/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
1. To compare performance or metrics across dimensions or time periods.
2. To evaluate differences between categories.
3. Useful for A/B testing or regional comparisons.

SQL Functions Used:
1. SUM(), AVG(): Aggregates values for comparison.
2. Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;