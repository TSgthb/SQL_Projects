/*
===================================================================================
Script for Analyzing Music App Dataset
===================================================================================
1. Contains analytical queries on the `view_music_info` view.
2. Answers business questions related to artist performance, track popularity, streaming trends, audio features, and platform engagement.
3. Uses CTEs, subqueries, aggregation, filtering, window functions, and conditional logic to extract insights.
===================================================================================
*/


/*
===================================================================================
Section: Exploratory Data Analysis (EDA)
===================================================================================
Objective:
- Understand the structure and distribution of the dataset.
===================================================================================
*/

-- Total number of records
SELECT COUNT(*) AS total_rows
FROM dbo.music_info;
GO

-- Unique artist count
SELECT COUNT(DISTINCT artist) AS artists
FROM dbo.music_info;
GO

-- Unique album count
SELECT COUNT(DISTINCT album) AS albums
FROM dbo.music_info;
GO

-- Unique album types
SELECT COUNT(DISTINCT album_type) AS album_types
FROM dbo.music_info;
GO

-- Longest and shortest song durations
SELECT 
    MAX(duration_min) AS longest_song_time,
    MIN(duration_min) AS minimum_song_time
FROM dbo.music_info;
GO

-- Unique channels
SELECT DISTINCT channel
FROM dbo.music_info;
GO

-- Unique platforms where tracks are most played
SELECT DISTINCT most_played_on
FROM dbo.music_info;
GO

-- Preview top 5 records from the view
SELECT TOP (5) *  
FROM dbo.view_music_info;
GO

/*
===================================================================================
Section: Basic Aggregations and Filters
===================================================================================
*/

-- 1. Tracks with more than 1 billion streams
SELECT title
FROM dbo.view_music_info
WHERE no_of_streams > 1000000000;
GO

-- 2. List all albums with their respective artists
SELECT DISTINCT 
    album AS albums,
    artist
FROM dbo.view_music_info;
GO

-- 3. Total comments for licensed tracks
SELECT SUM(no_of_comments) AS total_comments
FROM dbo.view_music_info
WHERE LOWER(licensed_status) = 'true';
GO

-- 4. Tracks that belong to album type 'single'
SELECT DISTINCT
    track,
    artist
FROM dbo.view_music_info
WHERE album_type = 'single'
ORDER BY track;
GO

-- 5. Count of total tracks by each artist
SELECT 
    artist,
    COUNT(*) AS total_records
FROM dbo.view_music_info
GROUP BY artist
ORDER BY total_records DESC;
GO

/*
===================================================================================
Section: Aggregations and Grouped Metrics
===================================================================================
*/

-- 6. Average danceability per album
SELECT 
    album,
    AVG(danceability) AS avg_danc
FROM dbo.view_music_info
GROUP BY album
ORDER BY avg_danc DESC;
GO

-- 7. Top 5 tracks with highest energy
SELECT TOP (5)
    track,
    MAX(energy) AS max_energy
FROM dbo.view_music_info
GROUP BY track, album, artist
ORDER BY max_energy DESC;
GO

-- 8. Views and likes for tracks with official videos
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

-- 9. Total views per album
SELECT
    album,
    artist,
    SUM(no_of_views) AS total_views
FROM dbo.view_music_info
GROUP BY track, album, artist
ORDER BY total_views DESC;
GO

-- 10. Tracks most played on Spotify
SELECT DISTINCT
    track,
    album
FROM dbo.view_music_info 
WHERE most_played_on = 'Spotify';
GO

/*
===================================================================================
Section: Category 3 – Advanced Analysis with Window Functions
===================================================================================
*/

-- 11. Top 3 most-viewed tracks per artist
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

-- 12. Tracks with liveness above average
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

-- 13. Energy difference per album
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

-- 14. Tracks with energy-to-liveness ratio > 1.2
SELECT 
    track,
    album,
    artist,
    energy_liveness
FROM dbo.view_music_info 
WHERE energy_liveness > 1.2
GROUP BY track, album, artist, energy_liveness;
GO

-- 15. Cumulative sum of likes ordered by views
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
