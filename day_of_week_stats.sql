/*
Запрос для построения графика зависимости среднего количетсва лайков
от дня недели. Для красоты графика вмсето цифр, которые возвращает 
EXTRACT(ISODOW FROM publish_datetime::date) прописывала названия дней недели.
*/
SELECT AVG(likes) as avg_likes_count, 
CASE 
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 1 THEN 'monday'
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 2  THEN 'tuesday'
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 3  THEN 'wednesday'
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 4  THEN 'thursday'
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 5  THEN 'friday'
	WHEN EXTRACT(ISODOW FROM publish_datetime::date) = 6  THEN 'saturday'
	ELSE 'sunday'
END AS weekday
FROM posts_stats
GROUP BY weekday
