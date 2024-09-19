/*
Запрос для построения графика зависимости среднего количетсва лайков
от времени суток. Утро, день, вечер и ночь определены несколько вольно:
утро с 5 до 11 часов, день с 11 до 17, вечер с 17 до 23, ну и ночь с 23 до 5.
*/
SELECT AVG(likes) as avg_likes_count,
CASE 
	WHEN publish_datetime::time BETWEEN '05:00'::TIME AND '11:00'::TIME THEN 'morning'
	WHEN publish_datetime::time BETWEEN '11:00:01'::TIME AND '17:00'::TIME THEN 'daytime'
	WHEN publish_datetime::time BETWEEN '17:00:01'::TIME AND '23:00'::TIME THEN 'evening'
	ELSE 'night'
END AS day_interval
FROM posts_stats
GROUP BY day_interval
