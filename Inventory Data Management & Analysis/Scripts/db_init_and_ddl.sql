/*
====================================================================================
Sript for creating the database and table for inventory data management and analytics
====================================================================================
*/ 

-- ==========================================
-- Create the database
-- ==========================================
CREATE DATABASE invent_db;
GO

-- ==========================================
-- Use database
-- ==========================================
USE invent_db;
GO

-- Loaded data from the csv file to the table, dbo.inventory using import functionality in SSMS.
  
-- ==========================================
-- Add a new primary key column as sku_id
-- ==========================================
  
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

