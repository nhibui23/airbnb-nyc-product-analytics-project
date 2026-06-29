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
--   4. Bronx has 37.2 (have fairly high rating but low-supply)
--
-- Additional to Python conclusion, Queens is the surprise leader
-- Despite having 9,338 existing listings, each one generates more guest engagement than other borough
-- This suggests that the underlying demand in Queens is not fully met. 

-- Meanwhile, Brooklyn and Manhattan, shows of market saturation with the most listings and lowest engagement per listing.

-- 9 of the top 10 highest-rated Queens combinations are Entire home/apt. Queens guests reward whole-apartment listings
---============================================================
-- RECOMMENDATION:

-- Adjust the growth strategy from only growing in Broxn to shifting resources to Queens as well:
-- 1. Inves in host acquisition in Queens where demand is clearly outpacing supply
-- 2. Continue to target growing in Bronx, specifically Mott Haven, Schuylerville, and Belmont 
-- 3. Shift reeources away from Brooklyn and Manhattan where supply is saturated
-- ============================================================


-- FOLLOW UP 3B. QUEENS NEIGHBORHOOD RECOMMENDATION 
-- Identify top-performing neighborhoods in Queens and the room type & pricing for hosts to target.

SELECT
neighbourhood, room_type,
COUNT(*) AS listings,
ROUND(AVG(price), 2) AS avg_price,
ROUND(MIN(price), 2) AS min_price,
ROUND(MAX(price), 2) AS max_price,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(minimum_nights), 1) AS avg_min_nights,
ROUND(AVG(availability_365), 0) AS avg_availability
FROM listings
WHERE neighbourhood_group = 'Queens'
GROUP BY neighbourhood, room_type
HAVING COUNT(*) >= 3
ORDER BY avg_review_rate DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Within Queens, the top-rated neighborhoods are:
-- 1. Briarwood (4 review rate with 33 listings)
-- 2. Laurelton (3.82)
-- 3. The cluster of Far Rockaway / Bayside / Rosedale / 
-- South Ozone Park / St. Albans (all 3.65-3.71)
--
-- Ridgewood (183 listings, 8.1 monthly reviews) is the volume and engagement leader

-- Pricing is consistent across all top performers ($530-$788), indicating Queens is a quality-driven market instead of differentiating based on price
-- ============================================================
-- RECOMMENDATION:

-- 1. Expand to high demand areas - Ridgewood, Maspeth, St. Albans, as these new hosts here enter an active market with engagement.
-- Build an in-product dashboard showing new hosts the average rating and price range for their neighborhood and room type combination. 
-- Right now, hosts onboarding into Queens have no visibility into which neighborhoods actually perform, as they default to well-known areas like Astoria, missing higher-quality opportunities in places like Briarwood or Ridgewood.

-- 2. Position smaller markets but top-tier ratings - Briarwood, Laurelton, Far 

-- 3. Pricing guidance for new Queens hosts: target $600-700 (the median of top performers), as below $530 signals quality concerns, while above $800 raises expectations for high ratings
-- Airbnb could build a "price fit" indicator on the listing creation flow: 
-- A host pricing too low or too high will see a warning 
-- This nudges hosts toward the price band where quality wins
-- ============================================================


-- FOLLOW UP 3C. BRONX MARKET LANDSCAPE
-- What pricing and room type should a new host target for top 3 of Bronx - Mott Haven, Schuylerville, and Belmont?

SELECT
neighbourhood, room_type,
COUNT(*) AS listings,
ROUND(AVG(price), 2) AS avg_price,
ROUND(MIN(price), 2) AS min_price,
ROUND(MAX(price), 2) AS max_price,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(minimum_nights), 1) AS avg_min_nights,
ROUND(AVG(availability_365), 0) AS avg_availability
FROM listings
WHERE neighbourhood IN ('Mott Haven', 'Schuylerville', 'Belmont')
GROUP BY neighbourhood, room_type
HAVING COUNT(*) >= 5
ORDER BY avg_review_rate DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Private rooms outperform Entire homes in 2 of 3 Bronx target neighborhoods, the opposite pattern from Queens (where Entire home dominates)
-- Belmont Private rooms (with 3.76 rating) beat Belmont Entire homes (2.89 rating) by 0.87 stars on similar listing counts.
-- Mott Haven shows the same pattern (3.59 vs 3.26)

-- The Belmont Entire home segment (9 listings, $799 avg, price floor $527) appears to be overpriced relative to quality 
-- Its small sample should also be taken into consideration for exceptional overpriced pricing
-- Bronx may not be ready to support a high-end Entire home tier yet.

-- Schuylerville is the outlier (Entire homes slightly higher than Private rooms) but the 11-listing sample is too small for confidence.
--============================================================
-- RECOMMENDATION:

-- 1. Build a neighborhood-specific recommendation. 
-- For Belmont and Mott Haven, the in-product message should suggest considering listing a Private room over full unit
-- This helps hosts match supply to what the local market rewards.
--
-- 2. Build a "price-quality fit" warning: if a host is pricing in the top quartile for their neighborhood and room type, surface the average rating at that price point. 
-- This encourages hosts to either reconsider the price or invest in quality improvements 
-- ============================================================
