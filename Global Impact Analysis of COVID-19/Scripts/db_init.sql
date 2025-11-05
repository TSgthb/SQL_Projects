/*
====================================================================================
Script for Creating the Database covid19_data
====================================================================================
*/

-- ==========================================
-- Create Database
-- ==========================================
CREATE DATABASE covid19_data;
GO

-- ==========================================
-- Use Database
-- ==========================================
USE covid19_data;
GO

-- ==========================================
-- Data Import Instructions (Manual Steps)
-- ==========================================
-- 1. Download the dataset from: https://docs.owid.io/projects/etl/api/covid/#download-data
-- 2. For deaths dataset:
--    - Move 'code', 'continent', and 'population' to columns A, B, and E respectively.
--    - Delete all columns after AE (starting from 'total_tests' to 'human_development_index').
--    - Save as deaths.csv
-- 3. For vaccinations dataset:
--    - Delete columns from E ('population') to AE ('reproduction_rate').
--    - Save as vaccinations.csv
-- 4. Import both datasets using SSMS Import Flat File wizard:
--    - Use FLOAT for decimal columns, BIGINT for whole numbers, DATETIME2 for dates, NVARCHAR for text.
--    - Allow NULLs on all columns except 'country' and 'date'.
