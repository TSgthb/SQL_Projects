/*
===================================================================================
Script for creating and populating the Movies & Shows dataset
===================================================================================
1. This script initializes the `movies_and_shows` database environment.
2. It drops and recreates the `movies_shows` table with appropriate schema.
3. It performs a BULK INSERT from a tab-delimited text file.
4. Key Features:
   a. Uses IF OBJECT_ID(...) IS NOT NULL to safely drop existing tables.
   b. Defines appropriate data types for each column.
   c. Imports data using BULK INSERT with tab delimiter.
===================================================================================
*/

-- ==========================================
-- Use Database: movies_and_shows
-- ==========================================
CREATE DATABASE movies_and_shows;
GO

-- ==========================================
-- Use Database: movies_and_shows
-- ==========================================
USE movies_and_shows;
GO

-- ==========================================
-- Drop Table if Exists: movies_shows
-- ==========================================
IF OBJECT_ID('dbo.movies_shows','U') IS NOT NULL
    DROP TABLE dbo.movies_shows;
GO

-- ==========================================
-- Create Table: movies_shows
-- ==========================================
CREATE TABLE movies_shows 
(
    ms_id VARCHAR(5),
    ms_type VARCHAR(10),
    title VARCHAR(250),
    director VARCHAR(550),
    casts VARCHAR(1050),
    country VARCHAR(550),
    date_added VARCHAR(55),
    release_year INT,
    rating VARCHAR(15),
    duration VARCHAR(15),
    listed_in VARCHAR(250),
    ms_description VARCHAR(550)
);
GO

-- ==========================================
-- Bulk Insert Data from Text File
-- ==========================================
BULK INSERT dbo.movies_shows
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Movies & Shows Dataset Analysis\Sources\netflix_titles.txt'
WITH
(
    FIRSTROW = 2,               -- Skip header row
    FIELDTERMINATOR = '\t',     -- Tab-delimited file
    TABLOCK                     -- Optimized bulk insert
);
GO
