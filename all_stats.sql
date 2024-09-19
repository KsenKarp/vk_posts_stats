/*
Используем для примерных вычислений формулу для коэффициента Спирмана: 
ρ = 1 - 6 * Σd^2 / (n^2 - n),
где d -- это разность рангов величин, для которых ищем зависимость,
а n -- количество наблюдений
*/

/*
Сначала собираю из таблицы со всеми данными posts_stats ранги для всех записей:
количество лайков ранжирую по возрастанию с помощью оконной функции RANK(),
а факторы, зависимость от которых мы пытаемся пронаблюдать, ранжируются естественным образом,
когда мы создаём под них бины
*/
WITH stats AS (
	SELECT DENSE_RANK() OVER (ORDER BY likes_count) as likes_count_rank, day_interval, weekday, interval_bins
	FROM (
		
	SELECT likes as likes_count,
	
	--1 соответствует временному промежутку утра, 2: день, 3: вечер, 4: ночь
	CASE 
		WHEN publish_datetime::time BETWEEN '05:00'::TIME AND '11:00'::TIME THEN 1
		WHEN publish_datetime::time BETWEEN '11:00:01'::TIME AND '17:00'::TIME THEN 2
		WHEN publish_datetime::time BETWEEN '17:00:01'::TIME AND '23:00'::TIME THEN 3
		ELSE 4
	END AS day_interval,
		
	--из даты публикации извлекаю день недели, 1 - понедельник, 7 - воскресенье
	EXTRACT(ISODOW FROM publish_datetime::date)::integer AS weekday,
	
	CASE
		WHEN prev_post IS NULL THEN null
		WHEN prev_post < INTERVAL '10 hours' THEN 1
		WHEN prev_post < INTERVAL '20 hours' THEN 2
		WHEN prev_post < INTERVAL '1day' THEN 3
		WHEN prev_post < INTERVAL '2 days' THEN 4
		WHEN prev_post < INTERVAL '3 days' THEN 5
		ELSE '6'
	END AS interval_bins
	
	FROM (
		SELECT likes, publish_datetime, publish_datetime - LEAD(publish_datetime) OVER(ORDER BY publish_datetime DESC) AS prev_post
		FROM posts_stats
	 ) --вычисляю с помощью функции LEAD() разницу во времени от предыдущего поста
		
	)
	--у самого первого поста не было предыдущего, поэтому и время от предыдущего поста
	--вычислить не можем, так что первый пост учитываться в дальнейших вычислениях не будет
	WHERE interval_bins IS NOT null 
)
--считаем d для каждой пары величин, зависимость между которыми исследуем
SELECT POWER(likes_count_rank - day_interval, 2) as likes_day_interval_delta, 
POWER(likes_count_rank - weekday, 2) as likes_weekday_delta, 
POWER(likes_count_rank - interval_bins, 2) as likes_interval_bins_delta
FROM stats;

--подставляем всё в формулу
SELECT (1 - 6 * SUM(likes_day_interval_delta)) / (COUNT(*) * (POWER(COUNT(*), 2) - 1)) as day_interval_spierman,
(1 - 6 * SUM(likes_weekday_delta)) / (COUNT(*) * (POWER(COUNT(*), 2) - 1)) as weekday_spierman,
(1 - 6 * SUM(likes_interval_bins_delta)) / (COUNT(*) * (POWER(COUNT(*), 2) - 1)) as posts_interval_spierman
FROM (
	SELECT POWER(likes_count_rank - day_interval, 2) as likes_day_interval_delta, 
	POWER(likes_count_rank - weekday, 2) as likes_weekday_delta, 
	POWER(likes_count_rank - interval_bins, 2) as likes_interval_bins_delta
	FROM stats
)