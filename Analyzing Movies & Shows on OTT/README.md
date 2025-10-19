# Analyzing Movies & Shows on OTT

## Project Overview

This project demonstrates the implementation of a data analysis pipeline for Netflix Movies and TV Shows using SQL Server to extract valuable insights and answer varioius various business questions.

## Objectives

1. **Set up a database and populate it with the provided data by importing it from a tab-delimited source.**
2. **Perform basic exploratory data analysis to understand dataset shape and distributions.**
3. **Use advanced SQL concepts such as CTEs, window functions and subqueries to answer complex business questions and derive actionable insights.**

## Project Structure

### 1. Database Setup

- **Database creation:** Create a database named `movies_and_sales`.
- **Table creation:** Create a table named `movies_shows` to store the data within the database.

```sql

-- ==========================================
-- Create Database: movies_and_shows
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
```

- **Data Insertion:** Data will be loaded using BULK INSERT from tab delimited file.
1. There was an error while importing the data at first:
   
![dirty](https://github.com/TSgthb/SQL_Projects/blob/b337d952951068f178f7190b0ed11de0e63dff80/Movies%20%26%20Shows%20Analysis/Documents/import_error.png)

2. The source file did not contained standardized data and hence, had to be cleaned before we could import it.

3. Upon further analysis, it was found that row, 8204 had some keywords from the description column of the record of the previous row.

![cleaned](https://github.com/TSgthb/SQL_Projects/blob/b337d952951068f178f7190b0ed11de0e63dff80/Movies%20%26%20Shows%20Analysis/Documents/record_incosistency.png)

4. We cleaned the record and were able to successfully import data using BULK INSERT

```sql  
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
```

### 2. Data Exploration & Advanced Analytics

- **The following queries answers business questions related to content type, release trends, genres, durations, cast appearances, and more.**
- **This section queries uses CTEs, subqueries, aggregation, ranking and string manipulation. It also shows the usage of application of filters for NULLs, empty strings, and specific patterns.**

**Task 1: Preview the Dataset**

```sql
-- ============================================================
-- Objective: View the first 5 records from the table.
-- ============================================================
SELECT TOP (5) * 
FROM dbo.movies_shows;
GO
```

**Task 2: Identify Duplicate Records by ms_id**

```sql
-- ============================================================
-- Objective: Find ms_id values that appear more than once.
-- ============================================================
SELECT 
    ms_id,
    COUNT(ms_id) AS total_val
FROM dbo.movies_shows
GROUP BY ms_id
HAVING COUNT(ms_id) > 1;
GO
```

**Task 3: List All Unique Content Types**

```sql
-- ============================================================
-- Objective: Get distinct values from the ms_type column.
-- ============================================================
SELECT DISTINCT
    ms_type
FROM dbo.movies_shows;
GO
```

**Task 4: Count Entities by Content Type**

```sql
-- ============================================================
-- Objective: Group and count by ms_type.
-- ============================================================
SELECT
    ms_type AS content_type,
    COUNT(ms_type) AS tot_entities
FROM dbo.movies_shows
GROUP BY ms_type;
GO
```

**Task 5: Filter Movies Released in 2021**

```sql
-- ============================================================
-- Objective: Get all movies released in the year 2021.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE release_year = 2021
      AND ms_type = 'Movie';
GO
```

**Task 6: Top Rating per Content Type**

```sql
-- ============================================================
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
```
**Task 7: Top 5 Countries by Content Count**

```sql
-- ============================================================
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
```

**Task 8: Analyze Duration Format for Movies**

```sql
-- ============================================================
-- Objective: Count how many durations contain 'min'.
-- ============================================================
SELECT TOP (5) 
    CHARINDEX('min', duration) AS pos_space,
    COUNT(CHARINDEX('min', duration)) AS count_pos_space
FROM dbo.movies_shows
WHERE ms_type = 'Movie'
GROUP BY CHARINDEX('min', duration);
GO
```

**Task 9: Longest Movie Durations**

```sql
-- ============================================================
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
```

**Task 10: Join Movies with Last 5 Years of Additions**

```sql
-- ============================================================
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
```

**Task 11: Filter by Specific Director**

```sql
-- ============================================================
-- Objective: Find all content directed by Rajiv Chilaka.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE director LIKE '%Rajiv Chilaka%';
GO
```

**Task 12: TV Shows with More Than 5 Seasons**

```sql
-- ============================================================
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
```

**Task 13: Count by Genre**

```sql
-- ============================================================
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
```

**Task 14: Yearly Content from India with Percent Share**

```sql
-- ============================================================
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
```

**Task 15: List All Documentary Movies**

```sql
-- ============================================================
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
```

**Task 16: Find Records with Missing Director InfoA**

```sql
-- ============================================================
-- Objective: Identify entries with NULL or blank director.
-- ============================================================
SELECT *
FROM dbo.movies_shows
WHERE director IS NULL
      OR director IN ('', ' ');
GO
```

**Task 17: Salman Khan Movies in the Last 10 Years**

```sql
-- ============================================================
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
```

**Task 18: Top 10 Most Frequent Indian Movie Actors**

```sql
-- ============================================================
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
```

**Task 19: Classify Content by Description Sentiment**

```sql
-- ============================================================
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
```

## Findings and Conclusion
- **Data Quality Observations:** Several records have missing or blank fields (e.g., director names), which could impact downstream analytics. These gaps should be addressed in future data cleaning steps.
- **Content Distribution:** The dataset reveals a healthy mix of movies and TV shows, with movies slightly dominating in volume. This helps understand Netflix’s content strategy and user engagement focus.
- **Rating Trends:** The most common ratings for both movies and TV shows are clustered around family-friendly categories like *TV-MA*, *TV-14*, and *PG-13*, indicating a broad target audience.
- **Temporal Insights:** A significant portion of content has been added in the last five years, showing Netflix’s aggressive content expansion strategy. The year-wise breakdown also highlights spikes in content acquisition.
- **Geographic Reach:** Countries like the United States, India, and the United Kingdom contribute the most content. India, in particular, shows a strong upward trend in recent years, with measurable year-over-year growth.
- **Genre Diversity:** The platform offers a wide range of genres, with *Dramas*, *Comedies*, and *Documentaries* being the most prevalent. This diversity supports Netflix’s global appeal.
- **Duration Patterns:** Most movies fall within the 90–120 minute range, while TV shows vary widely in season count. A subset of long-running shows (5+ seasons) indicates strong viewer loyalty.
- **Content Classification:** Using keyword-based sentiment tagging (e.g., presence of “kill” or “violence”), content was categorized into *Good*, *Bad*, or *Uncertain*. This can aid in content moderation or parental control features.

