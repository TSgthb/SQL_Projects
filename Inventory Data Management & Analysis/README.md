# Inventory Data Management & Analysis for Online Grocery Store

<p align="justify">
This project demonstrates the implementation of a simple data analysis pipeline for Zepto, an online grocery delivery store using SQL Server. It focuses on cleaning, transforming, and analyzing inventory data to extract actionable insights related to stock status, pricing, discount strategies, and category-level performance.
</p>

## Project Objectives

1. **Set up a database and prepare the inventory table by importing data from a csv file, assigning a primary key and standardizing data types.**
2. **Perform data cleaning to remove invalid records and normalize units.**
3. **Analyze inventory data to answer key business questions using SQL queries.**
4. **Generate insights on stock availability, pricing patterns, discount effectiveness, and category-level metrics.**

## Project Structure

### 1. Database Setup

- **Database creation:** Create a database named `invent_db`.

```sql

-- ==========================================
-- Create Database
-- ==========================================
CREATE DATABASE invent_db;
GO

-- ==========================================
-- Use Database
-- ==========================================
USE invent_db;
GO
```

- **Table creation:** Create a table named `inventory` to store the data within the database and import the data. The data has been directly loaded from CSV into the table, inventory (which gets created during the import), using SSMS import functionality. The steps are follows:

![load_csv](https://github.com/TSgthb/SQL_Projects/blob/06a724be3b0226a56184d8f8bbda46a94d4347b9/Inventory%20Data%20Management%20%26%20Analysis/Documents/Importing%20CSV%20File.png)

- **Standardizing table:** Add a primary key column and standardize other relevant columns.
  
```sql
-- ==================================================================
-- Add Primary Key Column (sku_id) using ROW_NUMBER() and %%physloc%%
-- ==================================================================
ALTER TABLE dbo.inventory
ADD sku_id INT;
GO

WITH num_rows AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_id,
        %%physloc%% AS row_loc
    FROM dbo.inventory
)
UPDATE inv
SET sku_id = nr.row_id
FROM dbo.inventory AS inv
INNER JOIN num_rows AS nr
    ON %%physloc%% = nr.row_loc;
GO

-- ==========================================
-- Enforce NOT NULL on category
-- ==========================================
ALTER TABLE dbo.inventory
ALTER COLUMN category INT NOT NULL;
GO

-- ==========================================
-- Add Primary Key Constraint
-- ==========================================
ALTER TABLE dbo.inventory
ADD CONSTRAINT PK_inventory_sku_id PRIMARY KEY (sku_id);
GO

-- ==========================================
-- Standardize Price Columns to DECIMAL
-- ==========================================
ALTER TABLE dbo.inventory
ALTER COLUMN mrp DECIMAL(8,2) NULL;
GO

ALTER TABLE dbo.inventory
ALTER COLUMN discountedSellingPrice DECIMAL(8,2) NULL;
GO
```

### 2. Data Exploration & Analytics

- **The following queries answer business questions related to product categories, pricing, stock status, discount strategies, and inventory weight.**
- **This section uses aggregation, conditional logic, filtering, and ranking. It also applies cleanup rules for NULLs and invalid pricing, and standardizes units for downstream analytics.**

1. **Count Total Records**

```sql
-- ============================================================
-- Objective: Get the total number of rows in the inventory table.
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM dbo.inventory;
GO
```

2. **Preview Sample Data**

```sql
-- ============================================================
-- Objective: View the first 10 records from the inventory table.
-- ============================================================
SELECT TOP (10) *
FROM dbo.inventory;
GO
```

3. **Check for NULLs in Key Columns**

```sql
-- ============================================================
-- Objective: Identify rows with missing values in critical fields.
-- ============================================================
SELECT *
FROM dbo.inventory
WHERE
    category IS NULL OR name IS NULL OR mrp IS NULL OR
    discountPercent IS NULL OR availableQuantity IS NULL OR
    discountedSellingPrice IS NULL OR weightInGms IS NULL OR
    outOfStock IS NULL OR quantity IS NULL;
GO
```

4. **List Distinct Product Categories**

```sql
-- ============================================================
-- Objective: Explore the variety of product categories.
-- ============================================================
SELECT DISTINCT category
FROM dbo.inventory;
GO
```

5. **Stock Status Summary**

```sql
-- ============================================================
-- Objective: Count products that are in stock vs. out of stock.
-- ============================================================
SELECT
    CASE outOfStock
        WHEN 1 THEN 'Out of stock'
        ELSE 'In stock'
    END AS stock_status,
    COUNT(*) AS stock_count
FROM dbo.inventory
GROUP BY
    CASE outOfStock
        WHEN 1 THEN 'Out of stock'
        ELSE 'In stock'
    END;
GO
```

6. **Identify Duplicate Product Names**

```sql
-- ============================================================
-- Objective: Find products with non-unique names.
-- ============================================================
SELECT 
    name,
    COUNT(*) AS count_products
FROM dbo.inventory
GROUP BY name
HAVING COUNT(*) > 1;
GO
```

7. **Delete Invalid Price Records**

```sql
-- ============================================================
-- Objective: Remove rows where MRP or discounted price is zero.
-- ============================================================
DELETE FROM dbo.inventory
WHERE sku_id IN (
    SELECT sku_id
    FROM dbo.inventory
    WHERE mrp = 0 OR discountedSellingPrice = 0
);
GO
```

8. **Convert Prices from Paise to Rupees**

```sql
-- ============================================================
-- Objective: Standardize pricing units for consistency.
-- ============================================================
UPDATE dbo.inventory
SET 
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
GO
```

9. **Top 10 Best-Value Products**

```sql
-- ============================================================
-- Objective: Rank products by highest discount percentage.
-- ============================================================
SELECT DISTINCT TOP (10)
    name,
    mrp,
    weightInGms,
    discountPercent
FROM dbo.inventory
ORDER BY discountPercent DESC;
GO
```

10. **Expensive Products Out of Stock**

```sql
-- ============================================================
-- Objective: Identify high-priced items that are unavailable.
-- ============================================================
SELECT DISTINCT
    name,
    mrp
FROM dbo.inventory
WHERE mrp > 300.00 AND outOfStock = 1;
GO
```

11. **Estimated Revenue by Category**

```sql
-- ============================================================
-- Objective: Calculate potential revenue per category.
-- ============================================================
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM dbo.inventory
GROUP BY category;
GO
```

12. **High-Price, Low-Discount Products**

```sql
-- ============================================================
-- Objective: Find premium products with minimal discounts.
-- ============================================================
SELECT
    name,
    mrp,
    discountPercent
FROM dbo.inventory
WHERE mrp > 500.00 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent ASC;
GO
```

13. **Top 5 Categories by Average Discount**

```sql
-- ============================================================
-- Objective: Rank categories by average discount percentage.
-- ============================================================
SELECT TOP (5)
    category,
    AVG(discountPercent) AS avg_discount_perc
FROM dbo.inventory
GROUP BY category
ORDER BY avg_discount_perc DESC;
GO
```

14. **Best Value Products Over 100g**

```sql
-- ============================================================
-- Objective: Evaluate products based on per-gram price.
-- ============================================================
SELECT DISTINCT
    name,
    discountedSellingPrice,
    weightInGms,
    ROUND(discountedSellingPrice / weightInGms, 2) AS discounted_sp_per_gram
FROM dbo.inventory
WHERE weightInGms > 100
ORDER BY discounted_sp_per_gram DESC;
GO
```

15. **Classify Products by Weight**

```sql
-- ============================================================
-- Objective: Label products as 'Light' or 'Heavy'.
-- ============================================================
SELECT *,
    CASE 
        WHEN weightInGms > 1000 THEN 'Heavy'
        ELSE 'Light'
    END AS weight_type
FROM dbo.inventory
ORDER BY weight_type DESC;
GO
```

16. **Total Inventory Weight by Category**

```sql
-- ============================================================
-- Objective: Calculate total weight in kilograms per category.
-- ============================================================
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue,
    ROUND(SUM((weightInGms * availableQuantity) / 1000.0), 2) AS tot_inventory_weight_kg
FROM dbo.inventory
GROUP BY category;
GO
```

## Findings and Conclusion

- **Data Quality:** Several rows had zero prices or NULLs in key fields. These were cleaned to ensure analytical accuracy.
  
- **Stock Distribution:** A majority of products are in stock, but a notable subset of high-MRP items are out of stock.
  
- **Discount Strategy:** Consumable categories such as Fruits & Vegetables and Meats, Fish & Eggs, offer significantly higher discounts, while premium products from Home & Cleaning, Personal Care and Health & Hygiene, have minimal discounts.
  
- **Revenue Potential:** Revenue is concentrated in a few high-volume categories, suggesting optimization opportunities.

- **Weight-Based Insights:** Products were classified as 'Light' or 'Heavy' to support logistics and packaging decisions.
  
- **Unit Normalization:** Price values were standardized from paise to rupees, and weight was aggregated in kilograms for clarity.
