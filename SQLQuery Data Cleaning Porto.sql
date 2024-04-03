SELECT *
FROM RBNBPT.dbo.CalendarPorto

SELECT *
FROM RBNBPT.dbo.ListingsPorto

--__________________________________________________

-- CLEANING
-- Separate the country council in the "host_location" column.

SELECT
	SUBSTRING (host_location, CHARINDEX(',', host_location) +1, LEN(host_location)) AS host_country
FROM RBNBPT.dbo.ListingsPorto

SELECT
	PARSENAME (REPLACE(host_location, ',', '.'), 2) AS host_city
FROM RBNBPT.dbo.ListingsPorto


ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD host_country NVARCHAR(255);

ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD host_city NVARCHAR(255);


UPDATE RBNBPT.dbo.ListingsPorto
SET host_country = SUBSTRING (host_location, CHARINDEX(',', host_location) +1, LEN(host_location))

UPDATE RBNBPT.dbo.ListingsPorto
SET host_city = PARSENAME (REPLACE(host_location, ',', '.'), 2)


UPDATE RBNBPT.dbo.ListingsPorto
SET host_country = CASE
		WHEN host_country = 'CA' THEN 'United States'
		WHEN host_country = 'NY' THEN 'United States'
		WHEN host_country = 'FL' THEN 'United States'
		WHEN host_country = 'MA' THEN 'United States'
		WHEN host_country = 'TX' THEN 'United States'
		WHEN host_country = 'OH' THEN 'United States'
		WHEN host_country = 'TN' THEN 'United States'
		WHEN host_country = 'Portugal, Portugal' THEN 'Portugal'
		WHEN host_country = 'Réunion, Réunion' THEN 'Réunion'
		ELSE host_country
		END


SELECT host_country, host_city
FROM RBNBPT.dbo.ListingsPorto

--__________________________________________________

-- Delete the blanks in these two new columns:

UPDATE RBNBPT.dbo.ListingsPorto
SET host_country = TRIM(host_country)

UPDATE RBNBPT.dbo.ListingsPorto
SET host_city = TRIM(host_city)


-- Since the empty cells here were not being considered NULL, I had to explicitly tell SQL to do so:

UPDATE RBNBPT.dbo.ListingsPorto
SET host_country = NULL
WHERE host_country = '';

--__________________________________________________

-- Remove the "%" and "N/A" symbols from the "host_response_rate" and host_acceptance_rate" columns

SELECT host_response_rate, host_acceptance_rate, REPLACE(REPLACE(host_response_rate, '%', ''), 'N/A', ''), REPLACE(REPLACE(host_acceptance_rate, '%', ''), 'N/A', '')
FROM RBNBPT.dbo.ListingsPorto


ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD percent_host_response_rate NVARCHAR(255);

ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD percent_host_acceptance_rate NVARCHAR(255);


UPDATE RBNBPT.dbo.ListingsPorto
SET percent_host_response_rate = REPLACE(REPLACE(host_response_rate, '%', ''), 'N/A', '')

UPDATE RBNBPT.dbo.ListingsPorto
SET percent_host_acceptance_rate = REPLACE(REPLACE(host_acceptance_rate, '%', ''), 'N/A', '')

-- Change the data type of the new columns:

ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN percent_host_response_rate DECIMAL (10, 2)

ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN percent_host_acceptance_rate DECIMAL (10, 2)


SELECT percent_host_response_rate, percent_host_acceptance_rate
FROM RBNBPT.dbo.ListingsPorto

--__________________________________________________

-- Replace "t" and "f" with "True" and "False" in the "host_is_superhost" column

SELECT DISTINCT(host_is_superhost)
FROM RBNBPT.dbo.ListingsPorto


UPDATE RBNBPT.dbo.ListingsPorto
SET host_is_superhost = CASE
		WHEN host_is_superhost = 't' THEN 'True'
		WHEN host_is_superhost = 'f' THEN 'False'
		ELSE host_is_superhost
		END

--__________________________________________________

-- Separate in the "bathrooms_text" column the number of toilets from the type of toilets.

ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD number_of_bathrooms NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsPorto
SET number_of_bathrooms = REPLACE(REPLACE(REPLACE(bathrooms_text, 'baths', ''), 'bath', ''), 'private', '')


ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD shared_or_not_shared_bathroom NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsPorto
SET shared_or_not_shared_bathroom = 'Shared'
WHERE number_of_bathrooms LIKE '%shared%';

UPDATE RBNBPT.dbo.ListingsPorto
SET shared_or_not_shared_bathroom = 'Not Shared'
WHERE shared_or_not_shared_bathroom IS NULL;


UPDATE RBNBPT.dbo.ListingsPorto
SET number_of_bathrooms = REPLACE(number_of_bathrooms, 'shared', '');

UPDATE RBNBPT.dbo.ListingsPorto
SET number_of_bathrooms = REPLACE(REPLACE(number_of_bathrooms, 'half-', '0.5'), 'Half-','0.5')


SELECT number_of_bathrooms, shared_or_not_shared_bathroom
FROM RBNBPT.dbo.ListingsPorto


ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN number_of_bathrooms DECIMAL (10, 1)

--__________________________________________________

-- Remove the "$" symbol from the "price" column of the "ListingsPorto" database

ALTER TABLE RBNBPT.dbo.ListingsPorto
ADD price_dollar NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsPorto
SET price_dollar = REPLACE(REPLACE(price, '$', ''), ',', '');


UPDATE RBNBPT.dbo.ListingsPorto
SET price_dollar = NULL
WHERE price_dollar = '';

ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN price_dollar DECIMAL (10, 2)

--__________________________________________________


-- Remove the "$" symbol from the "price" column of the "CalendarPorto" database

ALTER TABLE RBNBPT.dbo.CalendarPorto
ADD price_dollar NVARCHAR(255);

UPDATE RBNBPT.dbo.CalendarPorto
SET price_dollar = REPLACE(REPLACE(REPLACE(price, '$', ''), ',', ''), '"', '')

ALTER TABLE RBNBPT.dbo.CalendarPorto
ALTER COLUMN price_dollar DECIMAL (10, 2)

--__________________________________________________

-- Change the data type of the "review_scores_location" and "review_scores_value" columns to DECIMAL

UPDATE RBNBPT.dbo.ListingsPorto
SET review_scores_location = NULL
WHERE review_scores_location = '';

UPDATE RBNBPT.dbo.ListingsPorto
SET review_scores_value = NULL
WHERE review_scores_value = '';


ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN review_scores_location DECIMAL (10, 2)

ALTER TABLE RBNBPT.dbo.ListingsPorto
ALTER COLUMN review_scores_value DECIMAL (10, 2)

--__________________________________________________

-- Checking for duplicates

SELECT DISTINCT COUNT(id)
FROM RBNBPT.dbo.ListingsPorto

-- There are no duplicates