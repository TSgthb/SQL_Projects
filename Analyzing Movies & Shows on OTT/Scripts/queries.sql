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

-- ============================================================
-- Task 3: List All Unique Content Types
-- Objective: Get distinct values from the ms_type column.
-- ============================================================
SELECT DISTINCT
    ms_type
FROM dbo.movies_shows;
GO

-- ============================================================
-- Task 4: Count Entities by Content Type
-- Objective: Group and count by ms_type.
-- ============================================================
SELECT
    ms_type AS content_type,
    COUNT(ms_type) AS tot_entities
FROM dbo.movies_shows
GROUP BY ms_type;
GO

-- ============================================================
-- Task 5: Filter Movies Released in 2021
-- Objective: Get all movies released in the year 2021.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE release_year = 2021
      AND ms_type = 'Movie';
GO

-- ============================================================
-- Task 6: Top Rating per Content Type
-- Objective: Rank ratings by frequency within each ms_type.
-- ============================================================
WITH ranked_ms AS (
    SELECT
        ms_type,
        rating,
        COUNT(ms_id) AS tot_ratings,
        RANK() OVER (PARTITION BY ms_type ORDER BY COUNT(ms_id) DESC) AS rank_ratings
    FROM dbo.movies_shows
    GROUP BY ms_type, rating
)
SELECT
    rms.ms_type,
    rms.rating
FROM ranked_ms AS rms 
WHERE rms.rank_ratings = 1;
GO

-- ============================================================
-- Task 7: Top 5 Countries by Content Count
-- Objective: Split and count country values, then rank.
-- ============================================================
WITH cte_countries AS (
    SELECT
        TRIM(value) AS countries
    FROM dbo.movies_shows AS ms
    CROSS APPLY STRING_SPLIT(ms.country, ',')
    WHERE ms.country IS NOT NULL
),
grouped_countries AS (
    SELECT 
        countries,
        COUNT(countries) AS total_content
    FROM cte_countries
    WHERE countries <> ''
    GROUP BY countries
)
SELECT TOP (5) *
FROM grouped_countries
ORDER BY total_content DESC;
GO

-- ============================================================
-- Task 8: Analyze Duration Format for Movies
-- Objective: Count how many durations contain 'min'.
-- ============================================================
SELECT TOP (5) 
    CHARINDEX('min', duration) AS pos_space,
    COUNT(CHARINDEX('min', duration)) AS count_pos_space
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
GROUP BY CHARINDEX('min', duration);
GO

-- ============================================================
-- Task 9: Longest Movie Durations
-- Objective: Extract and sort movie durations numerically.
-- ============================================================
SELECT TOP (5)
    title,
    duration,
    CONVERT(INT, TRIM(REPLACE(duration, ' min', ''))) AS mov_run
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
      AND duration IS NOT NULL
      AND duration != ''
ORDER BY mov_run DESC;
GO

-- ============================================================
-- Task 10: Join Movies with Last 5 Years of Additions
-- Objective: Filter movies added in the most recent 5 years.
-- ============================================================
WITH last_5_years AS (
    SELECT TOP (5)
        CONVERT(INT, TRIM(RIGHT(date_added, 4))) AS year_added,
        COUNT(*) AS count_added
    FROM dbo.movies_shows
    WHERE date_added IS NOT NULL
    GROUP BY CONVERT(INT, TRIM(RIGHT(date_added, 4)))
    ORDER BY year_added DESC
)
SELECT 
    ms.*
FROM dbo.movies_shows AS ms
INNER JOIN last_5_years AS l5y
    ON CONVERT(INT, TRIM(RIGHT(ms.date_added, 4))) = l5y.year_added
ORDER BY CONVERT(INT, TRIM(RIGHT(ms.date_added, 4))) DESC;
GO

-- ============================================================
-- Task 11: Filter by Specific Director
-- Objective: Find all content directed by Rajiv Chilaka.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE director LIKE '%Rajiv Chilaka%';
GO

-- ============================================================
-- Task 12: TV Shows with More Than 5 Seasons
-- Objective: Extract and filter based on season count.
-- ============================================================
SELECT 
    ms_id,
    ms_type,
    title,
    casts,
    country,
    date_added,
    release_year,
    duration,
    listed_in,
    ms_description
FROM (
    SELECT *,
        CONVERT(INT, REPLACE(REPLACE(duration, ' Seasons', ''), 'Season', '')) AS season_count
    FROM dbo.movies_shows
    WHERE ms_type = 'TV Show'
) AS tv
WHERE season_count > 5
ORDER BY season_count DESC;
GO

-- ============================================================
-- Task 13: Count by Genre
-- Objective: Split and count genres from listed_in column.
-- ============================================================
SELECT
    TRIM(value) AS genre,
    COUNT(ms_id) AS tot_entities
FROM dbo.movies_shows
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE TRIM(value) IS NOT NULL 
      AND TRIM(value) != ''
GROUP BY TRIM(value);
GO

-- ============================================================
-- Task 14: Yearly Content from India with Percent Share
-- Objective: Calculate India's yearly contribution to content.
-- ============================================================
WITH india_piv AS (
    SELECT 
        CONVERT(INT, TRIM(RIGHT(date_added, 4))) AS year_added,
        COUNT(ms_id) AS count_added
    FROM dbo.movies_shows
    WHERE date_added IS NOT NULL
          AND date_added != ''
          AND country LIKE '%India%'
    GROUP BY CONVERT(INT, TRIM(RIGHT(date_added, 4)))
)
SELECT TOP (5)
    inp.year_added,
    inp.count_added AS yearly_entities,
    ROUND((inp.count_added / CONVERT(FLOAT, SUM(inp.count_added) OVER ()) * 100), 2) AS perc_yearly_count
FROM india_piv AS inp
GROUP BY inp.year_added, inp.count_added
ORDER BY perc_yearly_count DESC;
GO

-- ============================================================
-- Task 15: List All Documentary Movies
-- Objective: Filter movies with 'Doc' in genre.
-- ============================================================
SELECT 
    title,
    TRIM(value) AS genre
FROM dbo.movies_shows
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE ms_type = 'Movie'
      AND title IS NOT NULL
      AND title != ''
      AND TRIM(value) LIKE '%Doc%';
GO

-- ============================================================
-- Task 16: Find Records with Missing Director Info
-- Objective: Identify entries with NULL or blank director.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE director IS NULL
      OR director IN ('', ' ');
GO

-- ============================================================
-- Task 17: Salman Khan Movies in the Last 10 Years
-- Objective: Count movies by release year featuring Salman Khan.
-- ============================================================
SELECT 
    release_year,
    COUNT(ms_id) AS count_of_movies
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
      AND casts LIKE '%Salman Khan%'
GROUP BY release_year
HAVING CONVERT(INT, YEAR(GETDATE())) - release_year <= 10
ORDER BY release_year DESC;
GO

-- ============================================================
-- Task 18: Top 10 Most Frequent Indian Movie Actors
-- Objective: Count actor appearances in Indian movies.
-- ============================================================
SELECT TOP (10)
    TRIM(value) AS name_actor_or_actress,
    COUNT(ms_id) AS total_appearances
FROM dbo.movies_shows
CROSS APPLY STRING_SPLIT(casts, ',')
WHERE ms_type = 'Movie'
      AND country LIKE '%India%'
      AND casts != ''
      AND casts IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_appearances DESC;
GO

-- ============================================================
-- Task 19: Classify Content by Description Sentiment
-- Objective: Categorize content as Good, Bad, or Can't Say.
-- ============================================================
SELECT
    good_or_bad,
    COUNT(ms_id) AS tot_entities
FROM (
    SELECT *,
        CASE
            WHEN ms_description LIKE '%kill%' OR ms_description LIKE '%violence%' THEN 'Bad'
            WHEN ms_description IS NULL OR ms_description = '' THEN 'Can''t Say'
            ELSE 'Good'
        END AS good_or_bad
    FROM dbo.movies_shows
) AS sq
GROUP BY good_or_bad;
GO
