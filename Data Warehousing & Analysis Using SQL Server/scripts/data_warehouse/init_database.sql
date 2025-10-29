/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
1. This script creates a new database named 'data_warehouse' after checking if it already exists. 
2. If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.
	
Warning!:
1. Running this script will drop the entire 'data_warehouse' database if it exists. 
2. All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'data_warehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
    ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE data_warehouse;
END;
GO

-- Create the 'data_warehouse' database
CREATE DATABASE data_warehouse;
GO

USE data_warehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
