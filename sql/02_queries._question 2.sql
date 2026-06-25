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

-- Similarly, across all 4 room types, Instant Book provides no meaningful drive. 

-- Hotel rooms show the opposite pattern as  non-Instant Book hotel listings generate 36% more reviews (105.9 vs 77.9) AND higher ratings (3.58 vs 3.52), though the sample is tiny (91 listings)

-- All in all, we can conclude that Instant Book does not show any specific effect on any of the room types, price listings or boroughs
-- Sometimes, it shows contrasting patterns, as low-price listings and hotel rooms both perform worse with it.
-- ============================================================
-- RECOMMENDATION:

-- Instant Book is neither a growth lever nor a friction point worth product investment. 

-- Resources currently spent promoting it should redirect to availability tools, pricing guidance, and the monthly-stay product tier, which was also suggested earlier
-- ============================================================
