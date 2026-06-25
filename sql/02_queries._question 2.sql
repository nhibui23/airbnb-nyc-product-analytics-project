-- Question 2. DOES INSTANT BOOK DRIVE ENGAGEMENT?

-- FOLLOW UP 2A. INSTANT BOOK BY BOROUGH 
-- Maybe Instant Book doesn't help citywide, but does it help in less competitive markets like the Bronx? 

SELECT neighbourhood_group AS borough,
COUNT (*) AS total_listings,
SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END) AS instant_book_listing,
ROUND(100*SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END)/COUNT(*), 1) AS adoption_rate,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN review_rate_number END), 2) AS avg_rating_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN review_rate_number END), 2) AS avg_rating_no_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN number_of_reviews END), 1) AS avg_reviews_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN number_of_reviews END), 1) AS avg_reviews_no_ib
FROM listings
GROUP BY neighbourhood_group
ORDER BY total_listings DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Instant Book adoption is consistently ~50% across all NYC boroughs, so the comparison is well everywhere

-- The rating difference between Instant Book and non-Instant Book listings ranges from 0.00 (Staten Island) to 0.03 (Bronx) 

-- Similarly, review volume differences are also negligible (max 1.2 reviews on a base of 38+)
 
-- ============================================================
-- RECOMMENDATION:

-- Confirm the moving reources away from Instant Book as a growth lever for listings by boroughs
-- ============================================================


-- FOLLOW UP 2B. INSTANT BOOK BY PRICE SEGMENT 
-- Does Instant Book matter more for budget or premium listings?

SELECT
CASE 
WHEN price < 100  THEN '1. Under $100'
WHEN price < 300  THEN '2. $100-299'
WHEN price < 700  THEN '3. $300-699'
ELSE '4. $700+'
END AS price_segment,
COUNT(*) AS total_listings,
(SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END)) AS instant_book_listing,
ROUND(100*SUM(CASE WHEN instant_bookable = 'True' THEN 1 ELSE 0 END)/COUNT(*), 1) AS adoption_rate,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN review_rate_number END), 2) AS avg_rating_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN review_rate_number END), 2) AS avg_rating_no_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'True' THEN number_of_reviews END), 1) AS avg_reviews_ib,
ROUND(AVG(CASE WHEN instant_bookable = 'False' THEN number_of_reviews END), 1) AS avg_reviews_no_ib
FROM listings
GROUP BY price_segment
ORDER BY instant_book_listing DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Similarly, across all price tiers, Instant Book makes no measurable positive difference 

-- At the  price level Under $100, it correlates with worse outcomes (3.2 vs 3.3 stars, 34 vs 38 reviews). 
-- Therefore, the hypothesis that budget guests book more via Instant Book is contradicted by the data.
 
-- This pattern suggests hosts who manually screen bookings may be filtering out poor-fit guests
-- This would require host interview data to confirm.
-- ============================================================
-- RECOMMENDATION: 

-- Similarly, Airbnb should eprioritize Instant Book as a growth lever entirely, since it either has little to no effect or hurt the review rate number and number of reviews more for lower-price level

-- Investigate the low-price-tier screening hypothesis as a follow-up: 
-- Do non-Instant Book budget hosts have qualitatively different guest experiences than Instant Book budget hosts? 
-- If yes, Airbnb may want to build better guest-screening tools for budget hosts rather than push Instant Book on them.
-- ============================================================


-- FOLLOW UP 2C. INSTANT BOOK BY ROOM TYPE (with adoption rate)
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

-- Monthly stays (8-30 nights) achieve the highest average rating (3.34) 
-- 1-night stays generate 2.5x more reviews (48 vs 19)with a slighly lower review rating (3.30)
-- This is the same tradeoff seen in availability as monthly stays achieves a better rating, but 1-night has a better number of reviews  
-- Worst-performing tier is 4-7 nights (weekly), as it's neither short enough for spontaneous bookings nor long enough for guests to feel invested.
-- ============================================================
-- RECOMMENDATION:

-- 1. Introduce a "Monthly Stay" tier as a premium product targeted promotion to business travelers and temporary relocating visitors who need temporary housing by months
-- 2. Reduce platform fees as an incentive
-- 3. Position 1-night stays as a separate "Spontaneous Travel" tier with suggested quick maintenance and amenities for hosts (auto check-in, pricing changes for last-minute booking)
-- ============================================================

-- FOLLOW UP 1D. Of all the possible combinations of price, availability, and minimum nights, which specific profile produces the best-rated listings?
WITH listing_profiles AS (
SELECT
CASE
WHEN price < 150  THEN 'Budget'
WHEN price < 400  THEN 'Mid-range'
ELSE 'Premium'
END AS price_tier,

CASE
WHEN availability_365 <= 90  THEN 'Low availability'
WHEN availability_365 <= 200 THEN 'Medium availability'
ELSE 'High availability'
END AS availability_level,

CASE
WHEN minimum_nights <= 2  THEN 'Short stay (1-2)'
WHEN minimum_nights <= 7  THEN 'Week stay (3-7)'
ELSE 'Long stay (8+)'
END AS stay_type,
review_rate_number,
number_of_reviews
FROM listings
WHERE price > 0
)
SELECT price_tier, availability_level, stay_type,
COUNT(*) AS listings,
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(number_of_reviews), 2) AS avg_num_reviews
FROM listing_profiles
GROUP BY price_tier, availability_level, stay_type
HAVING COUNT(*) >= 50
ORDER BY avg_review_rate DESC
LIMIT 10;

-- ============================================================
-- KEY TAKEAWAY:

-- 1. Of the top 10 highest-rated listing profiles, 6 require "Long stay (8+ nights)" even when combined with price and availability tiers. Stay length is the dominant factor.

-- 2. The best profile: Budget + High availability + Long stay (3.42 stars)
-- This suggests that guests booking month- long stays at lower price points have more realistic expectations and rate accordingly.

-- 3. The worst profile: Premium + Low availability + Short stay
-- This suggests the high price with low commitment to guests' expectations and investment, which lowers the review rating

-- 4. Meanwhile, the tradeoff between high review rate number and low number of reviews still exists even with the 3 combined drivers together
-- Hosts thereby should make decisions by their priority of values
---- ============================================================
-- RECOMMENDATION:

-- 1. Airbnb should promote a "Long-Stay Host" certification program. Hosts who commit to a minimum 8-night booking policy and maintain 90%+ availability would earn a badge and improved search ranking. 
-- This helps Airbnb target the highest-rated segment of the platform - remote workers and relocating professionals 

-- 2. Airbnb should move resources away from the Premium + Short-stay segment (lowest in the top 10 despite being the most common profile with 8,057 listings) 
-- This will set up for guest disappointment.
-- ============================================================