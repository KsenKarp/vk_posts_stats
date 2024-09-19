import csv
import psycopg2

conn = psycopg2.connect("host=localhost dbname=vk_wonderful_photos user=postgres")
cur = conn.cursor()

with open('output.csv', 'r') as f:
    reader = csv.reader(f, delimiter=';')
    next(reader) #Пропускаем заголовок
    for row in reader:
        cur.execute(
            "INSERT INTO posts_stats (post_number, post_id, publish_datetime, likes) VALUES(" +
            str(row[0]) + "," + str(row[1]) + "," + "'" + row[2] + "'" + "," + str(row[3]) + ")")

conn.commit()
