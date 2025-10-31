/*
===================================================================================
Script for Analyzing Inventory Dataset
===================================================================================
1. This script contains a series of analytical and data-cleaning queries on the `inventory` table.
2. It answers business questions related to product categories, pricing, stock status,
   discount strategies, and inventory weight.
3. Key Features:
   a. Uses aggregation, conditional logic, filtering, and ranking.
   b. Applies cleanup rules for NULLs and invalid pricing.
   c. Standardizes units and prepares data for downstream analytics.
===================================================================================
*/

-- ============================================================
-- Task 1: Count Total Records
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM dbo.inventory;
GO

-- ============================================================
-- Task 2: Preview Sample Data
-- ============================================================
SELECT TOP (10) *
FROM dbo.inventory;
GO

-- ============================================================
-- Task 3: Check for NULLs in Key Columns
-- ============================================================
SELECT *
FROM dbo.inventory
WHERE
    category IS NULL OR name IS NULL OR mrp IS NULL OR
    discountPercent IS NULL OR availableQuantity IS NULL OR
    discountedSellingPrice IS NULL OR weightInGms IS NULL OR
    outOfStock IS NULL OR quantity IS NULL;
GO

-- ============================================================
-- Task 4: List Distinct Product Categories
-- ============================================================
SELECT DISTINCT category
FROM dbo.inventory;
GO

-- ============================================================
-- Task 5: Stock Status Summary
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

-- ============================================================
-- Task 6: Identify Duplicate Product Names
-- ============================================================
SELECT 
    name,
    COUNT(*) AS count_products
FROM dbo.inventory
GROUP BY name
HAVING COUNT(*) > 1;
GO

-- ============================================================
-- Task 7: Delete Invalid Price Records
-- ============================================================
DELETE FROM dbo.inventory
WHERE sku_id IN (
    SELECT sku_id
    FROM dbo.inventory
    WHERE mrp = 0 OR discountedSellingPrice = 0
);
GO

-- ============================================================
-- Task 8: Convert Prices from Paise to Rupees
-- ============================================================
UPDATE dbo.inventory
SET 
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
GO

-- ============================================================
-- Task 9: Top 10 Best-Value Products
-- ============================================================
SELECT DISTINCT TOP (10)
    name,
    mrp,
    weightInGms,
    discountPercent
FROM dbo.inventory
ORDER BY discountPercent DESC;
GO

-- ============================================================
-- Task 10: Expensive Products Out of Stock
-- ============================================================
SELECT 
    name,
    mrp
FROM dbo.inventory
WHERE mrp > 300.00 AND outOfStock = 1;
GO

-- ============================================================
-- Task 11: Estimated Revenue by Category
-- ============================================================
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM dbo.inventory
GROUP BY category;
GO

-- ============================================================
-- Task 12: High-Price, Low-Discount Products
-- ============================================================
SELECT
    name,
    mrp,
    discountPercent
FROM dbo.inventory
WHERE mrp > 500.00 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent ASC;
GO

-- ============================================================
-- Task 13: Top 5 Categories by Average Discount
-- ============================================================
SELECT TOP (5)
    category,
    AVG(discountPercent) AS avg_discount_perc
FROM dbo.inventory
GROUP BY category
ORDER BY avg_discount_perc DESC;
GO

-- ============================================================
-- Task 14: Best Value Products Over 100g
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

-- ============================================================
-- Task 15: Classify Products by Weight
-- ============================================================
SELECT *,
    CASE 
        WHEN weightInGms > 1000 THEN 'Heavy'
        ELSE 'Light'
    END AS weight_type
FROM dbo.inventory
ORDER BY weight_type DESC;
GO

-- ============================================================
-- Task 16: Total Inventory Weight by Category
-- ============================================================
SELECT
    category,
    ROUND(SUM((weightInGms * availableQuantity) / 1000.0), 2) AS tot_inventory_weight_kg
FROM dbo.inventory
GROUP BY category;
GO
