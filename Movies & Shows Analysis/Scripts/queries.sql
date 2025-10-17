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

TRUNCATE TABLE dbo.movies_shows

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

SELECT 
    ms_id,
    COUNT(ms_id) AS total_val
FROM dbo.movies_shows
GROUP BY ms_id
HAVING COUNT(ms_id) > 1

SELECT DISTINCT
    ms_type
FROM dbo.movies_shows

SELECT
    ms_type AS content_type,
    COUNT(ms_type) AS tot_entities
FROM dbo.movies_shows
GROUP BY ms_type

SELECT
    *
FROM dbo.movies_shows
WHERE release_year = 2021
      AND
      ms_type = 'Movie'

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
