/*
====================================================================================
Script for Creating the Database and Table for Inventory Data Management and Analysis
====================================================================================
1. This script sets up the `invent_db` database and prepares the `inventory` table.
2. It adds a primary key, standardizes column types, and prepares the table for analysis.
3. Key Features:
   a. Uses ROW_NUMBER() and %%physloc%% to assign unique IDs.
   b. Converts price columns to DECIMAL for precision.
   c. Ensures schema consistency for downstream analytics.
====================================================================================
*/

-- ==========================================
-- Step 1: Create the Database
-- ==========================================
CREATE DATABASE invent_db;
GO

-- ==========================================
-- Step 2: Use the Database
-- ==========================================
USE invent_db;
GO

-- ==========================================
-- Step 3: Load Data
-- ==========================================
-- Data loaded from CSV into dbo.inventory using SSMS import functionality.

-- ==========================================
-- Step 4: Add a New Primary Key Column (sku_id)
-- ==========================================
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
-- Step 5: Enforce NOT NULL on Category Column
-- ==========================================
ALTER TABLE dbo.inventory
ALTER COLUMN category INT NOT NULL;
GO

-- ==========================================
-- Step 6: Add Primary Key Constraint
-- ==========================================
ALTER TABLE dbo.inventory
ADD CONSTRAINT PK_inventory_sku_id PRIMARY KEY (sku_id);
GO

-- ==========================================
-- Step 7: Update Data Types for Price Columns
-- ==========================================
ALTER TABLE dbo.inventory
ALTER COLUMN mrp DECIMAL(8,2) NULL;
GO

ALTER TABLE dbo.inventory
ALTER COLUMN discountedSellingPrice DECIMAL(8,2) NULL;
GO
