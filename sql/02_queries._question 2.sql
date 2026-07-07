
-- Question 2: Rank the top 10 highest-revenue-gap listings within each borough 
-- =====================================================
-- If Airbnb AI prototype launches with limited capacity (around only 500 hosts), which specific listings should we target first in each borough?  

WITH proxies AS (
    SELECT id, name, neighbourhood_group, price, review_rate_number,
           (365 - availability_365) / 365 AS occupancy_proxy,
           (365 - availability_365) / 365 * price * 365 AS estimated_revenue,
           0.7 * price * 365 - (365 - availability_365) / 365 * price * 365 AS revenue_gap
    FROM listings
    WHERE availability_365 IS NOT NULL
      AND price IS NOT NULL
      AND review_rate_number IS NOT NULL
),
ranked AS (
    SELECT id,name, neighbourhood_group, price, review_rate_number,
           ROUND(occupancy_proxy, 3) AS occupancy_proxy,
           ROUND(revenue_gap) AS revenue_gap,
           RANK() OVER (
               PARTITION BY neighbourhood_group
               ORDER BY revenue_gap DESC
           ) AS borough_rank
    FROM proxies
    WHERE review_rate_number >= 4.5 AND occupancy_proxy < 0.5
)
SELECT *
FROM ranked
WHERE borough_rank <= 10
ORDER BY neighbourhood_group, borough_rank;