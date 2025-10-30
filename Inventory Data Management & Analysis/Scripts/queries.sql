-- Created a new databse and switched to it

CREATE DATABASE invent_db;
GO

USE invent_db;
GO

-- Added a new primary key column as sku_id

ALTER TABLE dbo.inventory
    ADD sku_id INT;
GO

WITH num_rows AS
(
    SELECT 
        ROW_NUMBER() OVER(ORDER BY(SELECT NULL)) AS row_id,
        %%physloc%% AS row_loc
    FROM 
        dbo.inventory
)
UPDATE inv
    SET sku_id = nr.row_id
FROM dbo.inventory inv
    INNER JOIN num_rows nr 
        ON %%physloc%% = nr.row_loc
GO

ALTER TABLE dbo.inventory
ALTER COLUMN Category INT NOT NULL;
GO

ALTER TABLE dbo.inventory
ADD CONSTRAINT PK_inventory_sku_id PRIMARY KEY (sku_id)
GO

-- Count of rows

SELECT COUNT(*)
FROM dbo.inventory;
GO

-- Sample data

SELECT TOP (10) *
FROM dbo.inventory

-- Check NULLs

SELECT *
FROM 
    dbo.inventory
WHERE
    category IS NULL OR name is NULL OR mrp IS NULL OR
    discountPercent IS NULL OR availableQuantity IS NULL OR
    discountedSellingPrice IS NULL OR weightInGms IS NULL OR
    outOfStock IS NULL OR quantity IS NULL

-- Different product categories

SELECT DISTINCT category
FROM
    dbo.inventory

-- Products in stock vs. out of stock

SELECT
    CASE outOfStock
        WHEN  1 THEN 'Out of stock'
        ELSE 'In stock'
    END AS stock_status,
    COUNT(*) AS stock_count
FROM
    dbo.inventory
GROUP BY
     CASE outOfStock
        WHEN 1 THEN 'Out of stock'
        ELSE 'In stock'
     END
GO

-- Product names are unique or not

SELECT 
    name,
    COUNT(*) AS count_products
FROM 
    dbo.inventory
GROUP BY
    name
HAVING
    COUNT(*) > 1
GO

-- Data cleaning
-- Check and delete rows where prices are 0

DELETE FROM dbo.inventory
WHERE sku_id IN
                (
                    SELECT sku_id
                    FROM
                        dbo.inventory
                    WHERE 
                        mrp = 0 OR discountedSellingPrice = 0
                )

-- Update and standardize the units of prices Paise to Rupees

UPDATE dbo.inventory
SET 
    mrp = mrp/100,
    discountedSellingPrice = discountedSellingPrice/100

SELECT TOP (10) *
FROM dbo.inventory

ALTER TABLE dbo.inventory
ALTER COLUMN mrp DECIMAL(8,2) NULL;
GO

ALTER TABLE dbo.inventory
ALTER COLUMN discountedSellingPrice DECIMAL(8,2) NULL;
GO
