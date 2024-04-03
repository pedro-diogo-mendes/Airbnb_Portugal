-- ANALYSIS

-- After cleaning the data, let's try and find some insights in it.

SELECT
	id,
	host_id,
	host_name,
	host_country,
	host_city,
	host_is_superhost,
	neighbourhood_cleansed,
	neighbourhood_group_cleansed,
	latitude,
	longitude,
	property_type,
	room_type,
	accommodates,
	beds,
	price_dollar,
	review_scores_location,
	review_scores_value
FROM RBNBPT.dbo.ListingsPorto


-- Check the % of hosts that are Portuguese and of other Nationalities
-- In this query, we calculate the total count for each country, and then use the SUM function with the OVER() clause to get the grand total. Next, we divide each country's count by the grand total and multiply by 100 to get the percentage.

SELECT
    host_country,
    COUNT(DISTINCT host_id) AS total_hosts,
    CAST(COUNT(DISTINCT host_id) * 100.0 / SUM(COUNT(DISTINCT host_id)) OVER () AS DECIMAL (10, 2)) AS percentage_total_hosts
FROM
	RBNBPT.dbo.ListingsPorto
WHERE
    host_country IS NOT NULL
GROUP BY
    host_country
ORDER BY
    total_hosts DESC;

-- It should be noted that we only have 3161 hosts where we know the country of origin, and we have 5190 hosts in total, a difference from 2029:

SELECT COUNT (DISTINCT host_id)
FROM RBNBPT.dbo.ListingsPorto

SELECT COUNT (DISTINCT host_id)
FROM RBNBPT.dbo.ListingsPorto
WHERE host_country IS NOT NULL


-- Check the % of the total number of listings that are Portuguese or Foreign. How many listings are foreign?
-- We have a total of 13601 Listings

SELECT SUM(COUNT(id)) OVER ()
FROM RBNBPT.dbo.ListingsPorto


WITH TotalListings AS (
    SELECT
        COUNT(id) AS total_listings
    FROM RBNBPT.dbo.ListingsPorto
    WHERE host_country IS NOT NULL
)
SELECT
    host_country,
    COUNT(id) AS host_total,
    CAST(COUNT(id) * 100.0 / (SELECT total_listings FROM TotalListings) AS DECIMAL(10, 2)) AS host_listings_total_percent
FROM RBNBPT.dbo.ListingsPorto
WHERE host_country IS NOT NULL
GROUP BY host_country
ORDER BY host_total DESC;

--__________________________________________________

-- Check the percentage of hosts that are "Super Hosts".

WITH TotalHosts AS (
    SELECT
        COUNT(DISTINCT host_id) AS total_hosts
    FROM RBNBPT.dbo.ListingsPorto
    WHERE host_is_superhost IS NOT NULL
)
SELECT
    host_is_superhost,
    COUNT(DISTINCT host_id) AS host_total,
    CAST(COUNT(DISTINCT host_id) * 100.0 / (SELECT total_hosts FROM TotalHosts) AS DECIMAL(10, 2)) AS host_listings_total_percent
FROM RBNBPT.dbo.ListingsPorto
WHERE host_is_superhost IS NOT NULL
GROUP BY host_is_superhost
ORDER BY host_total DESC;

--__________________________________________________

-- Who are the hosts with the most listings?

WITH CTE_total_listings AS
(
SELECT host_name, host_id, host_country, host_url, COUNT(id) AS host_total
FROM RBNBPT.dbo.ListingsPorto
GROUP BY host_name, host_id, host_country, host_url
)
SELECT host_name, host_id, host_country, host_url, MAX(host_total) AS total_listings
FROM CTE_total_listings
GROUP BY host_name, host_id, host_country, host_url
ORDER BY 5 DESC

--__________________________________________________

-- Where are Airbnb located in the district and what are the average prices?
-- Global in all parishes of the district of Porto:

SELECT neighbourhood_group_cleansed, neighbourhood_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsPorto
GROUP BY neighbourhood_group_cleansed, neighbourhood_cleansed
ORDER BY 3 DESC;

-- We can be more specific and check only in the parishes of the council of Porto:
SELECT neighbourhood_group_cleansed, neighbourhood_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsPorto
WHERE neighbourhood_group_cleansed = 'Porto'
GROUP BY neighbourhood_group_cleansed, neighbourhood_cleansed
ORDER BY 3 DESC;

-- Here we see by council in the district of Porto.

SELECT neighbourhood_group_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsPorto
GROUP BY neighbourhood_group_cleansed
ORDER BY 3 DESC;

--__________________________________________________

-- What types of accommodations are most common? And where are they?

SELECT
	room_type,
    COUNT(room_type) AS total_room_type,
    CAST((COUNT(room_type) * 100.0) / SUM(COUNT(room_type)) OVER () AS DECIMAL(10, 2)) AS percent_total_room_type
FROM RBNBPT.dbo.ListingsPorto
GROUP BY room_type
ORDER BY 2 DESC;


-- Where are they?

SELECT
	room_type,
	neighbourhood_group_cleansed,
	COUNT(room_type) AS total_room_type,
	CAST((COUNT(room_type) * 100.0) / SUM(COUNT(room_type)) OVER (PARTITION BY room_type) AS DECIMAL(10, 2)) AS percent_total_room_type
FROM RBNBPT.dbo.ListingsPorto
GROUP BY room_type, neighbourhood_group_cleansed
ORDER BY 1, 3 DESC;


-- What type of accommodation is the most expensive on average?

SELECT AVG(price_dollar), room_type
FROM RBNBPT.dbo.ListingsPorto
GROUP BY room_type
ORDER BY 1 DESC

--__________________________________________________

-- How many people can Porto accommodate? And only in Porto and Gaia, being the most touristic destinations?
-- Compare then with the number of tourists in Porto.

-- Total:

SELECT SUM(accommodates)
FROM RBNBPT.dbo.ListingsPorto

-- city:

SELECT neighbourhood_group_cleansed, SUM(accommodates)
FROM RBNBPT.dbo.ListingsPorto
GROUP BY neighbourhood_group_cleansed
ORDER BY 2 DESC

-- Now, only Porto and Gaia, as they are the two places where tourists stay the most, when visiting Porto.

SELECT SUM(accommodates)
FROM RBNBPT.dbo.ListingsPorto
WHERE neighbourhood_group_cleansed = 'PORTO' OR neighbourhood_group_cleansed = 'VILA NOVA DE GAIA'


--__________________________________________________

-- Compare the price with the number of beds and rooms. Checking if having more beds or rooms is synonymous with getting cheaper.

--Beds:

SELECT beds, CAST(AVG(price_dollar) AS DECIMAL (10, 2)) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsPorto
WHERE beds IS NOT NULL AND room_type <> 'Shared room' AND accommodates >= beds
GROUP BY beds
ORDER BY 1 DESC

-- Determine the price per bed
SELECT beds, CAST(AVG(price_dollar) AS DECIMAL (10, 2)) AS avg_price_dollar, CAST(AVG(price_dollar)/beds AS DECIMAL (10, 2)) AS avg_price_per_bed_dollar
FROM RBNBPT.dbo.ListingsPorto
WHERE beds IS NOT NULL AND room_type <> 'Shared room' AND accommodates >= beds
GROUP BY beds
ORDER BY 1 DESC


-- bedrooms:

SELECT beds, CAST(AVG(price_dollar) AS DECIMAL (10, 2)) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsPorto
WHERE beds IS NOT NULL AND room_type <> 'Shared room' AND accommodates >= beds
GROUP BY beds
ORDER BY 1 DESC

--__________________________________________________


-- Total average reviews

SELECT CAST(AVG(review_scores_value) AS DECIMAL (10, 1))
FROM RBNBPT.dbo.ListingsPorto

-- Where do you have the best Ratings in the district?

SELECT neighbourhood_group_cleansed, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsPorto
GROUP BY neighbourhood_group_cleansed
ORDER BY 2 DESC


-- Where do you have the best Ratings in the city of Porto?

SELECT neighbourhood_cleansed, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsPorto
WHERE neighbourhood_group_cleansed = 'PORTO'
GROUP BY neighbourhood_cleansed
ORDER BY 2 DESC


-- What type of property has the best ratings?

SELECT room_type, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsPorto
GROUP BY room_type
ORDER BY 2 DESC


-- Where are the best rated Airbnb in terms of location in the city of Porto?

SELECT neighbourhood_cleansed, CAST(AVG(review_scores_location) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsPorto
WHERE neighbourhood_group_cleansed = 'PORTO'
GROUP BY neighbourhood_cleansed
ORDER BY 2 DESC


-- Check the price fluctuation over time in all listings in the district of Porto

SELECT date, AVG(price_dollar)
FROM RBNBPT.dbo.CalendarPorto
GROUP BY date
ORDER BY date
