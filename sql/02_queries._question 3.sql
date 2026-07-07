
-- Question 3: Categorize each target host to the correct recommendation path
-- =====================================================
-- For each host in the target segment, does Airbnb AI prototype send them a "chase reviews" recommendation ora "focus on positioning" recommendation?
--
-- Segmentation logic:
--   * number_of_reviews < 50 -> Review-building path
--   * number_of_reviews >= 50 -> Positioning path

WITH proxies AS (
    SELECT id, name, neighbourhood_group, price, review_rate_number, number_of_reviews,
           (365 - availability_365) / 365 AS occupancy_proxy
    FROM listings
    WHERE availability_365 IS NOT NULL
      AND price IS NOT NULL
      AND review_rate_number IS NOT NULL
      AND number_of_reviews IS NOT NULL
),
target_segment AS (
    SELECT *,
           CASE
               WHEN number_of_reviews < 50 THEN 'Review-building path'
               ELSE 'Positioning path'
           END AS recommendation_path
    FROM proxies
    WHERE review_rate_number >= 4.5 AND occupancy_proxy < 0.5
)
SELECT recommendation_path,
       COUNT(*)  AS hosts_in_path,
       ROUND(AVG(number_of_reviews), 1) AS avg_reviews,
       ROUND(AVG(occupancy_proxy), 3) AS avg_occupancy,
       ROUND(AVG(price)) AS avg_price
FROM target_segment
GROUP BY recommendation_path
ORDER BY hosts_in_path DESC;