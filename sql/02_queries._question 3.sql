-- Question 3. WHERE SHOULD AIRBNB FOCUS GROWTH?


-- FOLLOW UP 3A. SUPPLY AND DEMAND BY BOROUGH OF BRONX
-- Listing count tells Airbnb about supply of Bronx, but it doesn't tell if this  market is underserved with lost of demand or saturated with more supply needed
-- Compare listing count (supply) vs total reviews (demand)
-- This ratio shows where each listing generates more guest engagement on average

SELECT
neighbourhood_group AS borough,
COUNT(*) AS total_listings,
SUM(number_of_reviews) AS total_reviews,
ROUND(SUM(number_of_reviews) * 1 / COUNT(*), 1) AS reviews_per_listing,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(availability_365), 0) AS avg_availability,
ROUND(AVG(price), 2) AS avg_price
FROM listings
GROUP BY neighbourhood_group
ORDER BY reviews_per_listing DESC;


-- ============================================================
-- KEY TAKEAWAY:

-- Previous Python analysis identified Bronx as the growth opportunity based on high ratings & low supply
-- Based on SQL analysis, the ranking shifts:
--
--   1. Queens has 42.5 reviews/listing (with the highest demand)
--   2. Staten Island has 39.2 (highest ratings at 3.39)
--   4. Bronx — 37.2 (have fairly high rating but low-supply)
--
-- Additional to Python conclusion, Queens is the surprise leader
-- Despite having 9,338 existing listings, each one generates more guest engagement than other borough
-- This suggests that the underlying demand in Queens is not fully met. 

-- Meanwhile, Brroklyn and Manhattan, shows of market saturation with the most listings and lowest engagement per listing.
---============================================================
-- RECOMMENDATION:

-- Adjust the growth strategy from only growing in Broxn to shifting resources to Queens as well:
-- 1. Inves in host acquisition in Queens where demand is clearly outpacing supply
-- 2. Continue to target growing in Bronx, specifically Mott Haven, Schuylerville, and Belmont 
-- 3. Shift reeources away from Brooklyn and Manhattan where supply is saturated
-- ============================================================


-- FOLLOW UP 3B. QUEENS MARKET LANDSCAPE
-- What do current Bronx listings look like? 

SELECT
neighbourhood,
COUNT(*) AS listings,
ROUND(AVG(price), 2) AS avg_price,
ROUND(MIN(price), 2) AS min_price,
ROUND(MAX(price), 2) AS max_price,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(minimum_nights), 1) AS avg_min_nights,
ROUND(AVG(availability_365), 0) AS avg_availability
FROM listings
WHERE neighbourhood_group = 'Queens'
GROUP BY neighbourhood
HAVING COUNT(*) >= 5
ORDER BY listings DESC;

-- ============================================================

-- FOLLOW UP 3C. BRONX MARKET LANDSCAPE
-- What do current Bronx listings look like? 

SELECT
neighbourhood,
COUNT(*) AS listings,
ROUND(AVG(price), 2) AS avg_price,
ROUND(MIN(price), 2) AS min_price,
ROUND(MAX(price), 2) AS max_price,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(minimum_nights), 1) AS avg_min_nights,
ROUND(AVG(availability_365), 0) AS avg_availability
FROM listings
WHERE neighbourhood_group = 'Bronx'
GROUP BY neighbourhood
HAVING COUNT(*) >= 5
ORDER BY listings DESC;

-- ============================================================

-- FOLLOW UP 3D. QUEENS NEIGHBORHOOD RECOMMENDATION 
-- Does Instant Book matter more for different types of room?

SELECT
room_type,
COUNT(*) AS total_listings,
SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END) AS instant_book_listings,
ROUND(100 * SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END) / COUNT(*),1) AS adoption_rate,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN review_rate_number END), 2) AS avg_rating_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN review_rate_number END), 2) AS avg_rating_no_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN number_of_reviews END), 1) AS avg_reviews_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN number_of_reviews END), 1) AS avg_reviews_no_ib
FROM listings
GROUP BY room_type
ORDER BY total_listings DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Similarly, across all 4 room types, Instant Book provides no meaningful drive. 

-- Hotel rooms show the opposite pattern as  non-Instant Book hotel listings generate 36% more reviews (105.9 vs 77.9) AND higher ratings (3.58 vs 3.52), though the sample is tiny (91 listings)

-- All in all, we can conclude that Instant Book does not show any specific effect on any of the room types, price listings or boroughs
-- Sometimes, it shows contrasting patterns, as low-price listings and hotel rooms both perform worse with it.
-- ============================================================
-- RECOMMENDATION:

-- Instant Book is neither a growth lever nor a friction point worth product investment. 

-- Resources currently spent promoting it should redirect to availability tools, pricing guidance, and the monthly-stay product tier, which was also suggested earlier
-- ============================================================
