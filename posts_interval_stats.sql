/*
Запрос для построения графика зависимости среднего количетсва лайков
от времени, прошедшего, с публикации с предыдущего поста. Это время 
разбивается на 7 категорий, одна из которых соответствует первому посту
и не участвует в рассмотрении. Деление на бины было выбрано так после
предварительного ознакомления со всеми интервалами времени, прошедшего, 
с публикации с предыдущего поста, для этого также были найдены 8-квантили*/

SELECT AVG(likes) as avg_likes_count, interval_bins FROM (
	SELECT likes, CASE 
		WHEN prev_post IS NULL THEN null
		WHEN prev_post < INTERVAL '10 hours' THEN 'less than 10h'
		WHEN prev_post < INTERVAL '20 hours' THEN 'less than 20h'
		WHEN prev_post < INTERVAL '1day' THEN 'between 20h and 24h'
		WHEN prev_post < INTERVAL '2 days' THEN 'between 1 and 2 days'
		WHEN prev_post < INTERVAL '3 days' THEN 'between 2 and 3 days'
		ELSE 'more than 3 days'
	END AS interval_bins
	FROM (
		SELECT likes, publish_datetime - LEAD(publish_datetime) OVER(ORDER BY publish_datetime DESC) AS prev_post
		FROM posts_stats
	 )
)
WHERE interval_bins IS NOT NULL
GROUP BY interval_bins
ORDER BY interval_bins;