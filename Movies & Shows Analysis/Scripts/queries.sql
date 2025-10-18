USE movies_and_shows;
GO

IF OBJECT_ID('dbo.movies_shows','U') IS NOT NULL
	DROP TABLE dbo.movies_shows
GO

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
)
GO

BULK INSERT dbo.movies_shows
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Movies & Shows Dataset Analysis\Sources\netflix_titles.txt'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    TABLOCK
)
GO

SELECT TOP (5) * 
FROM dbo.movies_shows
GO

SELECT 
    ms_id,
    COUNT(ms_id) AS total_val
FROM dbo.movies_shows
GROUP BY ms_id
HAVING COUNT(ms_id) > 1
GO

SELECT DISTINCT
    ms_type
FROM dbo.movies_shows
GO

SELECT
    ms_type AS content_type,
    COUNT(ms_type) AS tot_entities
FROM dbo.movies_shows
GROUP BY ms_type
GO
	
SELECT
    *
FROM dbo.movies_shows
WHERE release_year = 2021
      AND
      ms_type = 'Movie'
GO
	
WITH ranked_ms AS
(
SELECT
    ms_type,
    rating,
    COUNT(ms_id) AS tot_ratings,
    RANK() OVER (PARTITION BY ms_type ORDER BY COUNT(ms_id) DESC) AS rank_ratings
FROM dbo.movies_shows
GROUP BY
    ms_type,
    rating
)
SELECT
    rms.ms_type,
    rms.rating
FROM ranked_ms AS rms 
WHERE rms.rank_ratings = 1
GO
	
SELECT TOP(5) *
FROM dbo.movies_shows;
GO

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

SELECT TOP (5) 
--    title,
--  duration,
    CHARINDEX('min',duration) AS pos_space,
    COUNT(CHARINDEX('min',duration)) AS count_pos_space
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
GROUP BY CHARINDEX('min',duration)
GO

SELECT TOP (5)
    title,
    duration,
    CONVERT(INT,TRIM(REPLACE(duration,' min',''))) AS mov_run
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
      AND duration IS NOT NULL
      AND duration != ''
ORDER BY mov_run DESC
GO

WITH last_5_years AS
(
SELECT TOP (5)
--  title,
--  date_added,
    CONVERT(INT,TRIM(RIGHT(date_added,4))) AS year_added,
    COUNT(TRIM(RIGHT(date_added,4))) AS count_added
FROM dbo.movies_shows
WHERE date_added IS NOT NULL
GROUP BY CONVERT(INT,TRIM(RIGHT(date_added,4)))
ORDER BY year_added DESC
)
SELECT 
      ms.*
FROM dbo.movies_shows AS ms
     INNER JOIN last_5_years AS l5y
     ON CONVERT(INT,TRIM(RIGHT(ms.date_added,4))) = l5y.year_added
ORDER BY CONVERT(INT,TRIM(RIGHT(ms.date_added,4))) DESC
GO

SELECT *
FROM dbo.movies_shows
WHERE director LIKE '%Rajiv Chilaka%'
GO
 
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

SELECT
    TRIM(value) AS genre,
    COUNT(ms_id) AS tot_entities
FROM dbo.movies_shows
CROSS APPLY STRING_SPLIT(listed_in,',')
WHERE TRIM(value) IS NOT NULL 
      AND TRIM(value) != ''
GROUP BY TRIM(value)
GO

WITH india_piv AS
(
SELECT 
    CONVERT(INT,TRIM(RIGHT(date_added,4))) AS year_added,
    COUNT(ms_id) AS count_added
FROM dbo.movies_shows
WHERE date_added IS NOT NULL
      AND date_added != ''
      AND country LIKE '%India%'
GROUP BY CONVERT(INT,TRIM(RIGHT(date_added,4)))
)
SELECT TOP (5)
    inp.year_added,
    inp.count_added AS yearly_entities,
    --SUM(inp.count_added) OVER () AS tot_release_india,
    ROUND((inp.count_added/CONVERT(FLOAT,SUM(inp.count_added) OVER ())*100),2) AS perc_yearly_count
FROM india_piv AS inp
GROUP BY 
    inp.year_added,
    inp.count_added
ORDER BY perc_yearly_count DESC
GO

SELECT 
    title,
    TRIM(value) AS genre
FROM dbo.movies_shows
     CROSS APPLY STRING_SPLIT(listed_in,',')
WHERE 
    ms_type = 'Movie'
    AND
    title IS NOT NULL
    AND
    title != ''
    AND
    TRIM(value) LIKE '%Doc%'
GO

SELECT *
FROM dbo.movies_shows
WHERE
    director IS NULL
    OR
    director IN ('', ' ')
GO

SELECT 
    release_year,
    COUNT(ms_id) AS count_of_movies
FROM dbo.movies_shows
WHERE 
	ms_type = 'Movie'
    AND
    casts LIKE '%Salman Khan%'
GROUP BY release_year
HAVING CONVERT(INT,YEAR(GETDATE())) - release_year <= 10
ORDER BY release_year DESC
GO

SELECT TOP (10)
    TRIM(value) AS name_actor_or_actress,
    COUNT(ms_id) AS total_appearances
FROM dbo.movies_shows
     CROSS APPLY STRING_SPLIT(casts,',')
WHERE 
    ms_type = 'Movie'
    AND
    country LIKE '%India%'
    AND
    casts != ''
    AND
    casts IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_appearances DESC
GO

SELECT
    good_or_bad,
    COUNT(ms_id) AS tot_entities
FROM
    (
    SELECT
        *,
        CASE
            WHEN ms_description LIKE '%kill%' OR ms_description LIKE '%violence' THEN 'Bad'
            WHEN ms_description IS NULL OR ms_description = '' THEN 'Can''t Say'
            ELSE 'Good'
        END AS good_or_bad
    FROM dbo.movies_shows
    ) AS sq
GROUP BY good_or_bad
GO
