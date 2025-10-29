# Exploring Music Application Data

This project involves analyzing a Spotify dataset with various attributes about tracks, albums and artists using SQL and answer business questions related to artist performance, track popularity, streaming trends, audio features, and platform engagement. The tasks explored includes - setting up a database, importing, cleaning and standardizing data within it, performing exploratory and advance data analysis, and optimizing queries for optimal performance.


## Objectives

1. **Set up a database and populate it with the provided music application data.**
2. **Identify and remove records with missing or null values.**
3. **Perform basic exploratory data analysis to understand dataset shape and distributions.**
4. **Use SQL queries to answer business questions and derive actionable insights.**
5. **Optimize performance of analytical queries using indexes.**

## Project Structure

### 1. Database Setup

- **Database creation:** Create a database named `music_app_data`.

```sql
-- ==========================================
-- Create and Use Database
-- ==========================================
CREATE DATABASE music_app_data;
GO

USE music_app_data;
GO
```

- **Data import & table creation:** Import the dataset as a flatfile in a table named `music_info`. Verify the automatically declared data types for table columns and the data imported.

![data_import_using_flatfile](https://github.com/TSgthb/SQL_Projects/blob/b9eade5df30d862589312ac4d3f14b5a606b1424/Exploring%20Data%20from%20Music%20Application/Documents/importing_flat_file.png)

- **Data cleaning:** Remove the invalid records where the duration of the song is NULL, 0, blank or space.

```sql
-- ==========================================
-- Data Cleanup – Remove Invalid Durations
-- ==========================================
SELECT *
FROM dbo.music_info
WHERE duration_min IN (0, '', ' ')
      OR duration_min IS NULL;
GO

DELETE FROM dbo.music_info
WHERE duration_min IN (0, '', ' ');
GO
```

- **View creation:** Create a standardized view `view_music_info` on the clean data.

```sql
-- ==========================================
-- Create View for Cleaned Music Data
-- ==========================================
CREATE OR ALTER VIEW view_music_info AS
SELECT
    artist,
    track,
    album,
    album_type,
    danceability,
    energy,
    loudness,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    duration_min,
    channel,
    title,
    CONVERT(BIGINT, views) AS no_of_views,
    CONVERT(BIGINT, likes) AS likes,
    CONVERT(BIGINT, comments) AS no_of_comments,
    CASE 
        WHEN licensed = 'True' THEN 'True'
        ELSE 'False'
    END AS licensed_status,
    official_video,
    CONVERT(BIGINT, stream) AS no_of_streams,
    energy_liveness,
    most_played_on
FROM dbo.music_info;
GO
```

### 2. Exploratory Data Analysis and Aggregations

The queries in this section, helps us understand the structure and distribution of the dataset. These are:

**Task 1: Count Total Records**

```sql
-- ============================================================
-- Objective: Retrieve the total number of rows in the music_info table.
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM dbo.music_info;
GO
```

**Task 2: Count Unique Artists**

```sql
-- ============================================================
-- Objective: Get the number of distinct artists in the dataset.
-- ============================================================
SELECT COUNT(DISTINCT artist) AS artists
FROM dbo.music_info;
GO
```

**Task 3: Count Unique Albums**

```sql
-- ============================================================
-- Objective: Get the number of distinct albums in the dataset.
-- ============================================================
SELECT COUNT(DISTINCT album) AS albums
FROM dbo.music_info;
GO
```

**Task 4: Count Unique Album Types**

```sql
-- ============================================================
-- Objective: Get the number of distinct album types.
-- ============================================================
SELECT COUNT(DISTINCT album_type) AS album_types
FROM dbo.music_info;
GO
```

**Task 5: Song Duration Extremes**

```sql
-- ============================================================
-- Objective: Find the longest and shortest song durations.
-- ============================================================
SELECT 
    MAX(duration_min) AS longest_song_time,
    MIN(duration_min) AS minimum_song_time
FROM dbo.music_info;
GO
```

**Task 6: List Unique Channels**

```sql
-- ============================================================
-- Objective: Retrieve all distinct channel values.
-- ============================================================
SELECT DISTINCT channel
FROM dbo.music_info;
GO
```

**Task 7: List Unique Platforms**

```sql
-- ============================================================
-- Objective: Retrieve all distinct platforms where tracks are most played.
-- ============================================================
SELECT DISTINCT most_played_on
FROM dbo.music_info;
GO
```

**Task 8: Preview Top Records from View**

```sql
-- ============================================================
-- Objective: View the first 5 records from the view_music_info view.
-- ============================================================
SELECT TOP (5) *  
FROM dbo.view_music_info;
GO
```

**Task 9: Tracks with More Than 1 Billion Streams**

```sql
-- ============================================================
-- Objective: Retrieve track titles with over 1 billion streams.
-- ============================================================
SELECT title
FROM dbo.view_music_info
WHERE no_of_streams > 1000000000;
GO
```

**Task 10: List All Albums with Their Respective Artists**

```sql
-- ============================================================
-- Objective: Display distinct album names along with their artists.
-- ============================================================
SELECT DISTINCT 
    album AS albums,
    artist
FROM dbo.view_music_info;
GO
```

**Task 11: Total Comments for Licensed Tracks**

```sql
-- ============================================================
-- Objective: Calculate the total number of comments for licensed tracks.
-- ============================================================
SELECT SUM(no_of_comments) AS total_comments
FROM dbo.view_music_info
WHERE LOWER(licensed_status) = 'true';
GO
```

**Task 12: Tracks That Belong to Album Type 'Single'**

```sql
-- ============================================================
-- Objective: List distinct tracks and artists where album type is 'single'.
-- ============================================================
SELECT DISTINCT
    track,
    artist
FROM dbo.view_music_info
WHERE album_type = 'single'
ORDER BY track;
GO
```

**Task 13: Count of Total Tracks by Each Artist**

```sql
-- ============================================================
-- Objective: Count the number of tracks per artist and sort by count.
-- ============================================================
SELECT 
    artist,
    COUNT(*) AS total_records
FROM dbo.view_music_info
GROUP BY artist
ORDER BY total_records DESC;
GO
```

**Task 14: Average Danceability per Album**

```sql
-- ============================================================
-- Objective: Calculate the average danceability score for each album.
-- ============================================================
SELECT 
    album,
    AVG(danceability) AS avg_danc
FROM dbo.view_music_info
GROUP BY album
ORDER BY avg_danc DESC;
GO
```

**Task 15: Top 5 Tracks with Highest Energy**

```sql
-- ============================================================
-- Objective: Retrieve the top 5 tracks with the highest energy values.
-- ============================================================
SELECT TOP (5)
    track,
    MAX(energy) AS max_energy
FROM dbo.view_music_info
GROUP BY track, album, artist
ORDER BY max_energy DESC;
GO
```

**Task 16: Views and Likes for Tracks with Official Videos**

```sql
-- ============================================================
-- Objective: Summarize views and likes for tracks that have official videos.
-- ============================================================
SELECT
    track,
    album,
    artist,
    SUM(no_of_views) AS total_views,
    SUM(likes) AS total_likes
FROM dbo.view_music_info
WHERE official_video = 'True'
GROUP BY track, album, artist
ORDER BY total_views DESC, total_likes DESC;
GO
```

**Task 17: Total Views per Album**

```sql
-- ============================================================
-- Objective: Calculate total views for each album.
-- ============================================================
SELECT
    album,
    artist,
    SUM(no_of_views) AS total_views
FROM dbo.view_music_info
GROUP BY track, album, artist
ORDER BY total_views DESC;
GO
```

**Task 18: Tracks Most Played on Spotify**

```sql
-- ============================================================
-- Objective: List distinct tracks and albums most played on Spotify.
-- ============================================================
SELECT DISTINCT
    track,
    album
FROM dbo.view_music_info 
WHERE most_played_on = 'Spotify';
GO
```

### 3. Analytics and Insights using Advanced Concepts

The queries in this section, help extract insights using advanced SQL concepts such as CTEs, subqueries and window functions:

**Task 19: Top 3 Most-Viewed Tracks per Artist**

```sql
-- ============================================================
-- Objective: Retrieve the top 3 most-viewed tracks for each artist.
-- ============================================================
SELECT *
FROM (
    SELECT 
        TRIM(artist) AS clean_artist,
        TRIM(track) AS clean_track,
        SUM(no_of_views) AS total_views,
        ROW_NUMBER() OVER (PARTITION BY TRIM(artist) ORDER BY SUM(no_of_views) DESC) AS ranking_status
    FROM dbo.view_music_info
    GROUP BY artist, track
) fsq
WHERE fsq.ranking_status <= 3
ORDER BY fsq.clean_artist, fsq.ranking_status;
GO
```

**Task 20: Tracks with Liveness Above Average**

```sql
-- ============================================================
-- Objective: Identify tracks with liveness greater than the dataset average.
-- ============================================================
SELECT *
FROM (
    SELECT 
        TRIM(track) AS clean_track,
        liveness,
        AVG(liveness) OVER () AS avg_liveness
    FROM dbo.view_music_info
    GROUP BY artist, album, track, liveness
) fsq
WHERE fsq.liveness > fsq.avg_liveness
ORDER BY liveness DESC;
GO
```

**Task 21: Energy Difference per Album**

```sql
-- ============================================================
-- Objective: Calculate the energy range (max - min) for each album.
-- ============================================================
WITH energy_diff_album AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy,
        AVG(energy) AS avg_energy,
        COUNT(*) AS total_songs
    FROM dbo.view_music_info
    WHERE album_type = 'Album'
    GROUP BY album
)
SELECT 
    *,
    highest_energy - lowest_energy AS energy_difference
FROM energy_diff_album
ORDER BY energy_difference;
GO
```

**Task 22: Tracks with Energy-to-Liveness Ratio > 1.2**

```sql
-- ============================================================
-- Objective: Retrieve tracks where energy-to-liveness ratio exceeds 1.2.
-- ============================================================
SELECT 
    track,
    album,
    artist,
    energy_liveness
FROM dbo.view_music_info 
WHERE energy_liveness > 1.2
GROUP BY track, album, artist, energy_liveness;
GO
```

**Task 23: Cumulative Sum of Likes Ordered by Views**

```sql
-- ============================================================
-- Objective: Compute rolling sum of likes ordered by descending views.
-- ============================================================
WITH pivot_likes_views AS (
    SELECT
        track,
        album,
        MAX(likes) AS no_of_likes,
        MAX(no_of_views) AS total_views
    FROM dbo.view_music_info
    GROUP BY track, album
) 
SELECT
    plv.track,
    plv.no_of_likes,
    SUM(plv.no_of_likes) OVER (ORDER BY plv.total_views DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_sum_of_likes,
    plv.total_views
FROM pivot_likes_views AS plv;
GO
```

### 3. Query Optimizations

The general observations from our queries is that:

1. We are querying from a view (view_music_info) built on top of music_info.
2. The queries span basic aggregations, filtering, window functions, and CTEs.
3. Most queries are read-heavy and analytical, ideal for indexing and materialization strategies.

So, based on the above points, we can follow these recommendations to improve our performance of the queries:

1. Consider materializing the view `view_music_info` into a physical table. This avoids recomputation and speeds up downstream analytics.
2. For our analytical queries, the common pattern that is observed - `COUNT(DISTINCT ...)`, `SUM(...)`, `GROUP BY track, album, artist`, can benefit from the creation of a non-clustered index:

```sql
-- Composite index to support grouping and filtering
CREATE NONCLUSTERED INDEX idx_musicinfo_grouping
ON dbo.music_info (track, album, artist)
INCLUDE (likes, views, comments, official_video, licensed, stream);
```

Below are the before and after index implementation query execution statistics for **Task 23** as an example:

- Before index implementation:

![b4index](https://github.com/TSgthb/SQL_Projects/blob/66040c9a3e19ee02652061104522d2e61d1d92ce/Exploring%20Data%20from%20Music%20Application/Documents/b4_index.png)

- After index implementation (with lesser execution time):

![after_index](https://github.com/TSgthb/SQL_Projects/blob/66040c9a3e19ee02652061104522d2e61d1d92ce/Exploring%20Data%20from%20Music%20Application/Documents/after_index.png)

## Findings and Conclusions

- **Data Integrity**: Initial cleaning revealed several records with invalid or missing song durations. Removing these ensured more reliable analysis across duration-based metrics.
- **Content Distribution**: The dataset includes a diverse range of artists, albums, and track types. Singles dominate in volume, while albums show richer audio feature variation.
- **Engagement Insights**: Tracks with official videos consistently show higher views and likes, confirming the impact of visual content on listener engagement.
- **Platform Trends**: Spotify emerged as the most frequent platform for track playback, highlighting its dominance in music streaming.
- **Audio Feature Patterns**: Danceability and energy vary significantly across albums. High-energy tracks tend to correlate with higher stream counts, especially in top-performing artists.
- **Advanced Metrics**: Window functions revealed the top 3 most-viewed tracks per artist, while cumulative likes analysis helped identify momentum-building tracks.
- **Performance Optimization**: Materializing the view and implementing targeted indexes (e.g., on track, album, views) significantly reduced query execution time, especially for rolling aggregations.

