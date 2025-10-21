/*
===================================================================================
Script for Database Initialization and View Creation
===================================================================================
Objective:
- Create the `music_app_data` database.
- Perform basic data cleanup.
- Create a standardized view `view_music_info` for analysis.
===================================================================================
*/

-- ==========================================
-- Step 1: Create and Use Database
-- ==========================================
CREATE DATABASE music_app_data;
GO

USE music_app_data;
GO

-- ==========================================
-- Step 2: Data Cleanup – Remove Invalid Durations
-- ==========================================
SELECT *
FROM dbo.music_info
WHERE duration_min IN (0, '', ' ')
      OR duration_min IS NULL;
GO

DELETE FROM dbo.music_info
WHERE duration_min IN (0, '', ' ');
GO

-- ==========================================
-- Step 3: Create View for Cleaned Music Data
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
