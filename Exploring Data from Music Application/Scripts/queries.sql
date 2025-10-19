/*
===================================================================================
Script for analyzing Movies & Shows dataset
===================================================================================
1. This script contains a series of analytical queries on the `movies_shows` table.
2. It answers business questions related to content type, release trends, genres,
   durations, cast appearances, and more.
3. Key Features:
   a. Uses CTEs, subqueries, aggregation, ranking, and string manipulation.
   b. Applies filters for NULLs, empty strings, and specific patterns.
===================================================================================
*/

-- ============================================================
-- Task 1: Preview the Dataset
-- Objective: View the first 5 records from the table.
-- ============================================================
SELECT TOP (5) * 
FROM dbo.movies_shows;
GO

-- ============================================================
-- Task 2: Identify Duplicate Records by ms_id
-- Objective: Find ms_id values that appear more than once.
-- ============================================================
SELECT 
    ms_id,
    COUNT(ms_id) AS total_val
FROM dbo.movies_shows
GROUP BY ms_id
HAVING COUNT(ms_id) > 1;
GO
