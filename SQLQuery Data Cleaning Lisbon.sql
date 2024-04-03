SELECT *
FROM RBNBPT.dbo.CalendarLisbon;

SELECT *
FROM RBNBPT.dbo.ListingsLisbon;

--__________________________________________________

-- CLEANING

-- Separate the country council in the "host_location" column.

SELECT
	SUBSTRING (host_location, CHARINDEX(',', host_location) +1, LEN(host_location)) AS host_country
FROM RBNBPT.dbo.ListingsLisbon;

SELECT
	PARSENAME (REPLACE(host_location, ',', '.'), 2) AS host_city
FROM RBNBPT.dbo.ListingsLisbon;


ALTER TABLE RBNBPT.dbo.ListingsLisbon
ADD host_country NVARCHAR(255);

ALTER TABLE RBNBPT.dbo.ListingsLisbon
ADD host_city NVARCHAR(255);


UPDATE RBNBPT.dbo.ListingsLisbon
SET host_country = SUBSTRING (host_location, CHARINDEX(',', host_location) +1, LEN(host_location));

UPDATE RBNBPT.dbo.ListingsLisbon
SET host_city = PARSENAME (REPLACE(host_location, ',', '.'), 2);


UPDATE RBNBPT.dbo.ListingsLisbon
SET host_country = CASE
		WHEN host_country = 'CA' THEN 'United States'
		WHEN host_country = 'NY' THEN 'United States'
		WHEN host_country = 'FL' THEN 'United States'
		WHEN host_country = 'MA' THEN 'United States'
		WHEN host_country = 'TX' THEN 'United States'
		WHEN host_country = 'OH' THEN 'United States'
		WHEN host_country = 'TN' THEN 'United States'
		WHEN host_country = 'CO' THEN 'United States'
		WHEN host_country = 'CT' THEN 'United States'
		WHEN host_country = 'GA' THEN 'United States'
		WHEN host_country = 'IL' THEN 'United States'
		WHEN host_country = 'NC' THEN 'United States'
		WHEN host_country = 'NJ' THEN 'United States'
		WHEN host_country = 'OK' THEN 'United States'
		WHEN host_country = 'OR' THEN 'United States'
		WHEN host_country = 'PA' THEN 'United States'
		WHEN host_country = 'RI' THEN 'United States'
		WHEN host_country = 'Portugal, Portugal' THEN 'Portugal'
		WHEN host_country = 'Paço de Arcos e Caxias, Portugal' THEN 'Portugal'
		WHEN host_country = 'Réunion, Réunion' THEN 'Réunion'
		ELSE host_country
		END;


-- Delete the blanks in these two new columns:

UPDATE RBNBPT.dbo.ListingsLisbon
SET host_country = TRIM(host_country);

UPDATE RBNBPT.dbo.ListingsLisbon
SET host_city = TRIM(host_city);


-- Since the empty cells here were not being considered NULL, I had to explicitly tell SQL to do so:

UPDATE RBNBPT.dbo.ListingsLisbon
SET host_country = NULL
WHERE host_country = '';


-- Check:

SELECT DISTINCT host_country
FROM RBNBPT.dbo.ListingsLisbon
WHERE host_country IS NOT NULL;


--__________________________________________________

-- Replace "t" and "f" with "True" and "False" in the "host_is_superhost" column

SELECT DISTINCT(host_is_superhost)
FROM RBNBPT.dbo.ListingsLisbon;


UPDATE RBNBPT.dbo.ListingsLisbon
SET host_is_superhost = CASE
		WHEN host_is_superhost = 't' THEN 'True'
		WHEN host_is_superhost = 'f' THEN 'False'
		ELSE host_is_superhost
		END;


--__________________________________________________

-- Separate in the "bathrooms_text" column the number of toilets from the type of toilets.

ALTER TABLE RBNBPT.dbo.ListingsLisbon
ADD number_of_bathrooms NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsLisbon
SET number_of_bathrooms = REPLACE(REPLACE(REPLACE(bathrooms_text, 'baths', ''), 'bath', ''), 'private', '')


ALTER TABLE RBNBPT.dbo.ListingsLisbon
ADD shared_or_private_bathroom NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsLisbon
SET shared_or_private_bathroom = 'Shared'
WHERE number_of_bathrooms LIKE '%shared%';

UPDATE RBNBPT.dbo.ListingsLisbon
SET shared_or_private_bathroom = 'Not Shared'
WHERE shared_or_private_bathroom IS NULL;


UPDATE RBNBPT.dbo.ListingsLisbon
SET number_of_bathrooms = REPLACE(number_of_bathrooms, 'shared', '');

UPDATE RBNBPT.dbo.ListingsLisbon
SET number_of_bathrooms = REPLACE(REPLACE(number_of_bathrooms, 'half-', '0.5'), 'Half-','0.5')


UPDATE RBNBPT.dbo.ListingsLisbon
SET number_of_bathrooms = TRIM(number_of_bathrooms);


UPDATE RBNBPT.dbo.ListingsLisbon
SET number_of_bathrooms = NULL
WHERE number_of_bathrooms = '';


ALTER TABLE RBNBPT.dbo.ListingsLisbon
ALTER COLUMN number_of_bathrooms DECIMAL (10, 1)


SELECT DISTINCT number_of_bathrooms
FROM RBNBPT.dbo.ListingsLisbon

SELECT DISTINCT shared_or_private_bathroom
FROM RBNBPT.dbo.ListingsLisbon

--__________________________________________________

-- Remove the "$" symbol from the "price" column of the "ListingsLisbon" database

ALTER TABLE RBNBPT.dbo.ListingsLisbon
ADD price_dollar NVARCHAR(255);

UPDATE RBNBPT.dbo.ListingsLisbon
SET price_dollar = REPLACE(REPLACE(price, '$', ''), ',', '');


UPDATE RBNBPT.dbo.ListingsLisbon
SET price_dollar = NULL
WHERE price_dollar = '';

ALTER TABLE RBNBPT.dbo.ListingsLisbon
ALTER COLUMN price_dollar DECIMAL (10, 2)

--__________________________________________________


-- Remove the "$" symbol from the "price" column of the "CalendarLisbon" database

ALTER TABLE RBNBPT.dbo.CalendarLisbon
ADD price_dollar NVARCHAR(255);

UPDATE RBNBPT.dbo.CalendarLisbon
SET price_dollar = REPLACE(REPLACE(REPLACE(price, '$', ''), ',', ''), '"', '')

ALTER TABLE RBNBPT.dbo.CalendarLisbon
ALTER COLUMN price_dollar DECIMAL (10, 2)

--__________________________________________________

-- Change the data type of the "review_scores_location" and "review_scores_value" columns to DECIMAL

UPDATE RBNBPT.dbo.ListingsLisbon
SET review_scores_location = NULL
WHERE review_scores_location = '';

UPDATE RBNBPT.dbo.ListingsLisbon
SET review_scores_value = NULL
WHERE review_scores_value = '';


ALTER TABLE RBNBPT.dbo.ListingsLisbon
ALTER COLUMN review_scores_location DECIMAL (10, 2)

ALTER TABLE RBNBPT.dbo.ListingsLisbon
ALTER COLUMN review_scores_value DECIMAL (10, 2)


--__________________________________________________

-- Checking for duplicates

SELECT DISTINCT COUNT(id)
FROM RBNBPT.dbo.ListingsLisbon

SELECT COUNT(id)
FROM RBNBPT.dbo.ListingsLisbon

-- There are no duplicates