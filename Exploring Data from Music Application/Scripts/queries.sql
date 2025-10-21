/*
===================================================================================
Script for analyzing Movies & Shows dataset
===================================================================================

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

USE music_app_data;
GO

-- 3. List all tracks along with their views and likes where official_video = TRUE.

SELECT
	track,
	album,
	artist,
	SUM(no_of_views) AS total_views,
	SUM(likes) AS total_likes
FROM dbo.view_music_info
WHERE official_video = 'True'
GROUP BY
	track,
	album,
	artist
ORDER BY
	total_views DESC,
	total_likes DESC
GO

-- 4. For each album, calculate the total views of all associated tracks.

SELECT
	album,
	artist,
	SUM(no_of_views) AS total_views
FROM dbo.view_music_info
GROUP BY
	track,
	album,
	artist
ORDER BY
	total_views DESC
GO

-- 5. For each album, calculate the total views of all associated tracks.

/*
WITH views_and_streams AS
(
SELECT 
	track,
	album,
	artist,
	most_played_on,
	CASE
	WHEN LOWER(most_played_on) = 'YouTube' THEN MAX(no_of_streams)
	ELSE 0
	END AS most_streamed_on_YouTube,
	CASE
	WHEN LOWER(most_played_on) = 'Spotify' THEN MAX(no_of_streams)
	ELSE 0
	END AS most_streamed_on_Spotify
--	MAX(no_of_streams) AS total_streams,
--	MAX(no_of_views) AS total_views
	FROM dbo.view_music_info
GROUP BY
	track,
	album,
	artist,
	most_played_on
)
SELECT DISTINCT
	vas.track,
	vas.most_streamed_on_Spotify AS Spotify_rank
FROM views_and_streams AS vas
WHERE vas.most_streamed_on_Spotify != 0
ORDER BY Spotify_rank DESC
GO
*/

SELECT DISTINCT
			track,
			album
FROM dbo.view_music_info 
WHERE most_played_on = 'Spotify'
GO

-- Data Analysis - Category 3

-- 1. Find the top 3 most-viewed tracks for each artist using window functions.

SELECT *
FROM
	(
		SELECT 
			TRIM(artist) AS clean_artist,
			TRIM(track) AS clean_track,
			SUM(no_of_views) AS total_views,
			ROW_NUMBER() OVER (PARTITION BY TRIM(artist) ORDER BY SUM(no_of_views) DESC) AS ranking_status
		FROM dbo.view_music_info
--		WHERE artist = 'Aaron Smith'
		GROUP BY 
			artist,
			track
	) fsq
WHERE fsq.ranking_status <= 3
ORDER BY 
	fsq.clean_artist,
	fsq.ranking_status
GO

-- 2. Write a query to find tracks where the liveness score is above the average.

SELECT *
FROM
	(
		SELECT 
--			TRIM(artist) AS clean_artist,
--			TRIM(album) AS clean_album,
			TRIM(track) AS clean_track,
			liveness,
			AVG(liveness) OVER () AS avg_liveness
		FROM dbo.view_music_info
--		WHERE artist = 'Aaron Smith'
		GROUP BY 
			artist,
			album,
			track,
			liveness
	) fsq
WHERE fsq.liveness > fsq.avg_liveness
ORDER BY 
	liveness DESC
GO

-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH energy_diff_album AS
(
SELECT
	album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy,
	AVG(energy) AS avg_energy,
	COUNT(*) AS total_songs
FROM dbo.view_music_info
WHERE album_type = 'Album'
GROUP BY 
	album
)
SELECT 
	*,
	highest_energy - lowest_energy AS energy_difference
FROM energy_diff_album
ORDER BY energy_difference

-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
	track,
	album,
	artist,
	energy_liveness
FROM dbo.view_music_info 
WHERE energy_liveness > 1.2
GROUP BY
	track,
	album,
	artist,
	energy_liveness

-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

WITH pivot_likes_views AS
(
SELECT
	track,
	album,
	MAX(likes) AS no_of_likes,
	MAX(no_of_views) AS total_views
FROM dbo.view_music_info
GROUP BY
	track,
	album
) 
SELECT
	plv.track,
	plv.no_of_likes,
	SUM(plv.no_of_likes) OVER (ORDER BY plv.total_views DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_sum_of_likes,
	plv.total_views
FROM pivot_likes_views AS plv
GO
