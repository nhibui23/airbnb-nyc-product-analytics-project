-- Question 1. WHAT HOST FACTORS IMPACT REVIEW RATINGS?


-- FOLLOW UP 1A. For each borough + room type, which price tier gets the highest average review rate?

SELECT neighbourhood_group AS borough,
room_type,
CASE
WHEN price < 100 THEN 'Under $100'
WHEN price < 200 THEN '$100-199'
WHEN price < 500 THEN '$200-499'
WHEN price < 1000 THEN '$500-999'
ELSE '>$1000'
END AS price_tier, 
COUNT(*) AS listings, 
ROUND(AVG(review_rate_number)) AS avg_review_rate,
ROUND(AVG(number_of_reviews)) AS avg_number_of_reviews
FROM price_listings
GROUP BY neighbourhood_group, room_type, price_tier
HAVING COUNT (*) >=10
ORDER BY neighbourhood_group, room_type, avg_review_rate DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Premium pricing (>$1000) consistently shows slightly LOWER average ratings than mid-tier prices across most boroughs and room types 
-- This confirms our previous ANOVA finding that overpricing hurts ratings as guest expectations outpace delivery.
-- 
-- Outlier: Manhattan Hotel rooms generate 5x more reviews than Entire homes at the same price (around 156 reviews) 
-- This is a high-engagement niche worth further exploration in a future analysis
-- ============================================================
-- RECOMMENDATION:

-- Build a price-tier guidance feature for new hosts. When a host enters a price for a new listing, the platform should compare it to our listed median price for their borough + room type combination
-- If they're above the median, Airbnb can suggest a warning with a better price
-- This assisting in shifting hosts away from the overpricing trap
-- ============================================================


-- FOLLOW UP 1B. Even though availability is the strongest influence, which direction should hosts go?
-- Should a host list their property year-round, or limit availability?

SELECT 
CASE
WHEN availability_365 <= 90  THEN '1. Low (0-90 days)'
WHEN availability_365 <= 180 THEN '2. Medium (91-180 days)'
WHEN availability_365 <= 270 THEN '3. High (181-270 days)'
ELSE '4. Year-round (271-365 days)'
END AS availability,
COUNT(*) AS listings, 
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(number_of_reviews),2) AS avg_number_of_reviews
FROM listings
GROUP BY availability
HAVING COUNT (*) >=10
ORDER BY availability, listings, avg_review_rate DESC;

-- ============================================================
-- KEY TAKEAWAY:

-- Hosts who limit availability to <90 days achieve the highest average ratings (3.32) 
-- This confirms the maintenance break importance

-- As availability increases, ratings drop slightly (3.24 at high availability) while review volume climbs
-- This presents a tradeoff for hosts, as more open days lead to lower review rate number but higher number of reviews 

-- Our early ANOVA finding that availability matters most is validated
-- Availability direction is now clear for hosts: less availability is better for higher rating quality.
-- ============================================================
-- RECOMMENDATION:

-- 1. Add "Maintenance Mode" to encoruage having more maintenance break for better listing quality and guets experience
-- This should not interefere with their responsiveness rating during active mode on

-- 2. Suggest availability vs ratings vs number of ratings for host when setting availability
-- They can decide whether to trade off for review rating or number of reviews in general
-- ============================================================


-- FOLLOW UP 1C. Even though minimum night is also the strongest influence, which direction should hosts go?
-- Should they allow 1-night stays, require a week, or push for monthly?
SELECT 
CASE
WHEN minimum_nights = 1 THEN '1. 1 night'
WHEN minimum_nights BETWEEN 2 AND 3 THEN '2. 2-3 nights'
WHEN minimum_nights BETWEEN 4 AND 7 THEN '3. 4-7 nights (weekly)'
WHEN minimum_nights BETWEEN 8 AND 30 THEN '4. 8-30 nights (monthly)'
ELSE '5. 30+ nights (long-term)'
END AS min_nights_group,
COUNT(*) AS listings, 
ROUND(AVG(review_rate_number), 2) AS avg_review_rate,
ROUND(AVG(number_of_reviews),2) AS avg_number_of_reviews
FROM listings
GROUP BY min_nights_group
HAVING COUNT (*) >=10
ORDER BY avg_review_rate DESC;

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