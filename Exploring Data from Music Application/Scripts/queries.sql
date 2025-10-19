/*
===================================================================================
Script for analyzing Movies & Shows dataset
===================================================================================
*/

/*
CREATE DATABASE music_app_data;
GO

USE music_app_data;
GO
*/

-- EDA

SELECT COUNT(*) AS total_rows
FROM dbo.music_info;
GO

SELECT COUNT(DISTINCT artist) AS artists
FROM dbo.music_info;
GO

SELECT COUNT(DISTINCT album) AS albums
FROM dbo.music_info;
GO

SELECT COUNT(DISTINCT album_type) AS album_types
FROM dbo.music_info;
GO

SELECT 
	MAX(duration_min) AS longest_song_time,
	MIN(duration_min) AS minimum_song_time
FROM dbo.music_info;
GO

SELECT *
FROM dbo.music_info
WHERE duration_min IN (0,'',' ')
	  AND duration_min IS NULL
GO
DELETE FROM	dbo.music_info
WHERE duration_min IN (0,'',' ')
GO

SELECT DISTINCT channel
FROM dbo.music_info
GO

SELECT DISTINCT most_played_on
FROM dbo.music_info
GO

-- View

CREATE OR ALTER VIEW view_music_info AS
(
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
		CONVERT(BIGINT,music_info.views) AS no_of_views,
		CONVERT(BIGINT,music_info.likes) AS likes,
		CONVERT(BIGINT,music_info.comments) AS no_of_comments,
		CASE 
		WHEN licensed = 'True' THEN 'True'
		ELSE 'False'
		END AS licensed_status,
		official_video,
		CONVERT(BIGINT,music_info.stream) AS no_of_streams,
		energy_liveness,
		most_played_on
	FROM dbo.music_info
)
GO

SELECT TOP (5) *  
FROM dbo.view_music_info
GO						

-- Data Analysis - Category 1

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT title
FROM dbo.view_music_info
WHERE no_of_streams > 1000000000
GO

-- 2. List all albums along with their respective artists.

SELECT DISTINCT 
	album AS albums,
	artist
FROM dbo.view_music_info
GO

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(no_of_comments) AS total_comments
FROM dbo.view_music_info
WHERE LOWER(licensed_status) = 'true'
GO

-- 4. Find all tracks that belong to the album type single.

/*
WITH duplicate_tracks AS
(
SELECT 
	vmi.*,
	RANK() OVER (PARTITION BY vmi.track,vmi.artist,vmi.album ORDER BY vmi.no_of_streams DESC) AS rank_streams
FROM dbo.view_music_info vmi
	LEFT JOIN (
				SELECT 
					track,
					artist,
					album
				FROM dbo.view_music_info
			--	WHERE album_type = 'single' 
				GROUP BY
					track,
					artist,
					album
				HAVING COUNT(*) > 1 ) fsq
				ON vmi.track = fsq.track
)
SELECT  
	artist,
	COUNT(*) AS no_of_tracks
FROM duplicate_tracks
WHERE rank_streams = 1
GROUP BY
	artist
ORDER BY 
	no_of_tracks DESC,
	artist ASC
*/

SELECT DISTINCT
	track,
	artist
FROM dbo.view_music_info
WHERE album_type = 'single'
ORDER BY track
GO
-- 5. Count the total number of tracks by each artist.

SELECT 
	artist,
	COUNT(*) AS total_records
FROM dbo.view_music_info
--WHERE album_type = 'single'
GROUP BY 
	artist
ORDER BY total_records DESC
GO

-- Data Analysis - Category 2

-- 1. Calculate the average danceability of tracks in each album.

SELECT 
	album,
	AVG(danceability) AS avg_danc
FROM dbo.view_music_info
GROUP BY album
ORDER BY avg_danc DESC
GO

-- 2. Find the top 5 tracks with the highest energy values.

SELECT TOP (5)
	track,
	MAX(energy) AS max_energy
FROM dbo.view_music_info
GROUP BY 
	track,
	album,
	artist
ORDER BY max_energy DESC
GO

-- 3. Find the top 5 tracks with the highest energy values.
