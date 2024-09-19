CREATE OR REPLACE VIEW time_of_day AS (
	SELECT AVG(likes) as avg_likes_count,
	CASE 
		WHEN publish_datetime::time BETWEEN '05:00'::TIME AND '11:00'::TIME THEN 'morning'
		WHEN publish_datetime::time BETWEEN '11:00:01'::TIME AND '17:00'::TIME THEN 'daytime'
		WHEN publish_datetime::time BETWEEN '17:00:01'::TIME AND '23:00'::TIME THEN 'evening'
		ELSE 'night'
	END AS day_interval
	FROM posts_stats
	GROUP BY day_interval
);

SELECT * FROM time_of_day