-- Netflix project

-- create the table

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix( 
show_id	VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(210),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT * FROM netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows

SELECT rating, type
FROM (
SELECT rating, type, COUNT(*) AS total_count,
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS RANK
FROM netflix
GROUP BY 1,2
ORDER BY total_count DESC
) AS t1
WHERE rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE release_year = '2020'
AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1):: INT > 5;

-- 9. Count the number of content items in each genre

SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

-- 10. Find each year and the average number of content released in India on Netflix. 
-- return top 5 year with highest avg content release!

SELECT
EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) AS year,
COUNT(*) AS total_content,
ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::NUMERIC * 100, 2) AS probability
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE type = 'Movie'
AND listed_in ILIKE '%Documentaries%';

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor Salman Khan appeared in last 10 years!

SELECT COUNT(*) FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '10 YEARS');

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')),
COUNT(*) 
FROM netflix
WHERE type = 'Movie'
AND country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

SELECT 
CASE 
WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad'
ELSE 'Good'
END AS label,
COUNT (*)
FROM netflix
GROUP BY 1;

-- Thank You --