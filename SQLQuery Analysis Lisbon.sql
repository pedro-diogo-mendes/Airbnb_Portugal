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
	property_type,
	room_type,
	accommodates,
	beds,
	price_dollar,
	review_scores_location,
	review_scores_value
FROM RBNBPT.dbo.ListingsLisbon

-- Check the % of hosts that are Portuguese and of other Nationalities
-- In this query, we calculate the total count for each country, and then use the SUM function with the OVER() clause to get the grand total. Next, we divide each country's count by the grand total and multiply by 100 to get the percentage.

SELECT
    host_country,
    COUNT(DISTINCT host_id) AS total_hosts,
    CAST(COUNT(DISTINCT host_id) * 100.0 / SUM(COUNT(DISTINCT host_id)) OVER () AS DECIMAL (10, 2)) AS percentage_total_hosts
FROM
    RBNBPT.dbo.ListingsLisbon
WHERE
    host_country IS NOT NULL
GROUP BY
    host_country
ORDER BY
    total_hosts DESC;


-- It should be noted that we only have 6474 hosts where we know the country of origin, and we have 9079 hosts in total, a difference of 2605:

SELECT COUNT (DISTINCT host_id)
FROM RBNBPT.dbo.ListingsLisbon

SELECT COUNT (DISTINCT host_id)
FROM RBNBPT.dbo.ListingsLisbon
WHERE host_country IS NOT NULL


-- Check the % of the total number of listings that are Portuguese or Foreign. How many listings are foreign?
-- We have a total of 22751 Listings

SELECT SUM(COUNT(id)) OVER ()
FROM RBNBPT.dbo.ListingsLisbon


WITH TotalListings AS (
    SELECT
        COUNT(id) AS total_listings
    FROM RBNBPT.dbo.ListingsLisbon
    WHERE host_country IS NOT NULL
)
SELECT
    host_country,
    COUNT(id) AS host_total,
    CAST(COUNT(id) * 100.0 / (SELECT total_listings FROM TotalListings) AS DECIMAL(10, 2)) AS host_listings_total_percent
FROM RBNBPT.dbo.ListingsLisbon
WHERE host_country IS NOT NULL
GROUP BY host_country
ORDER BY host_total DESC;

--__________________________________________________

-- Check the percentage of hosts that are "Super Hosts".

WITH TotalHosts AS (
    SELECT
        COUNT(DISTINCT host_id) AS total_hosts
    FROM RBNBPT.dbo.ListingsLisbon
    WHERE host_is_superhost IS NOT NULL
)
SELECT
    host_is_superhost,
    COUNT(DISTINCT host_id) AS host_total,
    CAST(COUNT(DISTINCT host_id) * 100.0 / (SELECT total_hosts FROM TotalHosts) AS DECIMAL(10, 2)) AS host_listings_total_percent
FROM RBNBPT.dbo.ListingsLisbon
WHERE host_is_superhost IS NOT NULL
GROUP BY host_is_superhost
ORDER BY host_total DESC;

--__________________________________________________

-- Who are the hosts with the most listings?

WITH CTE_total_listings AS
(
SELECT host_name, host_id, host_country, host_url, COUNT(id) AS host_total
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY host_name, host_id, host_country, host_url
)
SELECT host_name, host_id, host_country, host_url, MAX(host_total) AS total_listings
FROM CTE_total_listings
GROUP BY host_name, host_id, host_country, host_url
ORDER BY 5 DESC

--__________________________________________________

-- Where are Airbnb located in the district and what are the average prices?
-- Global in all parishes of the district of Lisbon:

SELECT neighbourhood_group_cleansed, neighbourhood_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY neighbourhood_group_cleansed, neighbourhood_cleansed
ORDER BY 3 DESC;

-- We can be more specific and check only in the parishes of the council of Lisbon:

SELECT neighbourhood_group_cleansed, neighbourhood_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsLisbon
WHERE neighbourhood_group_cleansed = 'Lisboa' AND room_type = 'Entire home/apt'
GROUP BY neighbourhood_group_cleansed, neighbourhood_cleansed
ORDER BY 3 DESC;

-- Here we see by council in the district of Lisbon.

SELECT neighbourhood_group_cleansed, COUNT(neighbourhood_cleansed) AS total_count_neighbourhood, AVG(price_dollar) AS avg_price_dollar
FROM RBNBPT.dbo.ListingsLisbon
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
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY room_type, neighbourhood_group_cleansed
ORDER BY 1, 3 DESC;


-- What type of accommodation is the most expensive on average?

SELECT AVG(price_dollar) AS AVG_price, room_type
FROM RBNBPT.dbo.ListingsLisbon
WHERE (room_type <> 'shared room' OR price_dollar <= 1000) AND (room_type <> 'Private room' OR price_dollar <= 9999) AND (room_type <> 'Entire home/apt' OR price_dollar <= 9999) -- Fiz isto pois tinham aqui valores de umas casas acima de 9999 dolares, o que não fazia sentido.
GROUP BY room_type
ORDER BY 1 DESC

--__________________________________________________

-- How many people can Lisbon accommodate?
-- Compare then with the number of tourists in Lisbon.

-- Total:

SELECT SUM(accommodates)
FROM RBNBPT.dbo.ListingsLisbon

-- City:

SELECT neighbourhood_group_cleansed, SUM(accommodates)
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY neighbourhood_group_cleansed
ORDER BY 2 DESC


--__________________________________________________


-- Determine the price per bed

SELECT beds, CAST(AVG(price_dollar) AS DECIMAL (10, 2)) AS avg_price_dollar, CAST(AVG(price_dollar)/beds AS DECIMAL (10, 2)) AS avg_price_per_bed_dollar, COUNT(beds) AS NumberBeds
FROM RBNBPT.dbo.ListingsLisbon
WHERE beds IS NOT NULL AND room_type <> 'Shared room' AND accommodates >= beds
GROUP BY beds
ORDER BY 4 DESC


--__________________________________________________


-- Total average reviews

SELECT CAST(AVG(review_scores_value) AS DECIMAL (10, 1))
FROM RBNBPT.dbo.ListingsLisbon

-- Where do you have the best Ratings in the district?

SELECT neighbourhood_group_cleansed, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY neighbourhood_group_cleansed
ORDER BY 2 DESC


-- Where does it have the best Ratings in the city of Lisbon?

SELECT neighbourhood_cleansed, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsLisbon
WHERE neighbourhood_group_cleansed = 'Lisboa'
GROUP BY neighbourhood_cleansed
ORDER BY 2 DESC


-- What type of property has the best ratings?

SELECT room_type, CAST(AVG(review_scores_value) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsLisbon
GROUP BY room_type
ORDER BY 2 DESC


-- Where are the best rated Airbnb in terms of location in the city of Lisbon?

SELECT neighbourhood_cleansed, CAST(AVG(review_scores_location) AS DECIMAL (10, 2))
FROM RBNBPT.dbo.ListingsLisbon
WHERE neighbourhood_group_cleansed = 'Lisboa'
GROUP BY neighbourhood_cleansed
ORDER BY 2 DESC


-- Check the price fluctuation over time in all listings in the Lisbon district

SELECT date, AVG(price_dollar)
FROM RBNBPT.dbo.CalendarLisbon
GROUP BY date
ORDER BY date