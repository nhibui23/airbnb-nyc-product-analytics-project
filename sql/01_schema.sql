-- Create table without PRIMARY KEY 

DROP TABLE IF EXISTS listings;

CREATE TABLE listings (
	id                              BIGINT,
	name                            TEXT,
	host_id                         BIGINT,
	host_identity_verified          VARCHAR(20),
	neighbourhood_group             VARCHAR(50),
	neighbourhood                   VARCHAR(100),
	lat                             NUMERIC(10,6),
	long                            NUMERIC(10,6),
	instant_bookable                VARCHAR(10),
	cancellation_policy             VARCHAR(50),
	room_type                       VARCHAR(50),
	construction_year               NUMERIC(6,1),
	price                           NUMERIC(10,1),
	service_fee                     NUMERIC(10,1),
	minimum_nights                  NUMERIC(8,1),
	number_of_reviews               NUMERIC(8,1),
	last_review                     DATE,
	reviews_per_month               NUMERIC(6,2),
	review_rate_number              NUMERIC(4,1),
	calculated_host_listings_count  NUMERIC(6,1),
	availability_365                NUMERIC(6,1)
);

-- Load CSV into listings table

COPY listings
FROM 'C:\Project - data\Airbnb_Open_Data_Cleaned.csv'
WITH (FORMAT csv, HEADER true, NULL '');

-- Check for duplicates of id PRIMARY KEY
SELECT id, COUNT(*) AS count
FROM listings
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY count DESC
LIMIT 10;

-- Check for the number of duplicate values

SELECT COUNT(*) AS duplicate_ids
FROM (
SELECT id
FROM listings
GROUP BY id
HAVING COUNT(*) > 1
) AS duplicate;

-- With only 362 duplicate values, we can delete the duplicate rows with a higher address and keep only one copy of each id
DELETE FROM listings a
USING listings b
WHERE a.id = b.id
AND a.ctid > b.ctid;

-- Add PRIMARY KEY constraint back to the table
ALTER TABLE listings ADD PRIMARY KEY (id);

-- Check the table again to make sure the queries work
SELECT COUNT(*) AS total_rows FROM listings;