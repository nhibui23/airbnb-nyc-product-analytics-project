
-- Question 1. LIST OF UNUSED REVENUE LISTINGS
-- =====================================================
-- Which highly-rated NYC listings are currently underperforming on occupancy? 
-- These are the target users for Airbnb AI prototype.
--
-- Filter logic:
--   * review_rate_number >= 4.5   
--   * occupancy_proxy    < 0.5    

WITH proxies AS (
    SELECT id,name, neighbourhood_group, neighbourhood, price, review_rate_number, number_of_reviews,
           (365 - availability_365) / 365.0 AS occupancy_proxy,
           (365 - availability_365) / 365.0 * price * 365 AS estimated_revenue
    FROM listings
    WHERE availability_365 IS NOT NULL
      AND price IS NOT NULL
      AND review_rate_number IS NOT NULL
)
SELECT id, name, neighbourhood_group, neighbourhood, price, review_rate_number, number_of_reviews,
       ROUND(occupancy_proxy, 3) AS occupancy_proxy,
       ROUND(estimated_revenue) AS estimated_revenue,
       ROUND(0.70 * price * 365 - estimated_revenue) AS potential_gain
FROM proxies
WHERE review_rate_number >= 4.5 AND occupancy_proxy < 0.5
ORDER BY potential_gain DESC;