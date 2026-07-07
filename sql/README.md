# AirBnB NYC Analytics Project - SQL Analysis

* Project by Nhi Bui · Villanova University · [GitHub](https://github.com/nhibui23/airbnb-nyc-product-analytics-project) · [LinkedIn](https://linkedin.com/in/nhiuyenbui)

My SQL layer extracts the operational lists that power the Airbnb AI prototype. The Python notebooks discovered the pattern, while the SQL queries here pull the actual hosts a product team would target.

## Business Questions

**Q1. Who are the underperforming hosts?**
* Notebook 04 identified 6,412 highly-rated listings (>= 4.5 stars) with occupancy below 50%
* SQL pulls the full list with each host's specific revenue gap to hand off to the Vacancy Coach prototype

**Q2. In what order should Vacancy Coach roll out?**
* If the prototype launches with limited capacity, which specific listings should it target first?
* Here, my SQL ranks the top 10 highest-revenue-gap listings within each borough using a window function

**Q3. Which recommendation path does each host need?**
* Notebook 05 found the review count threshold is around 50 reviews 
* SQL will segment each host to the correct path: 4,851 hosts (76%) to the review-building path, 1,524 hosts (24%) to the positioning path

## SQL Techniques Used

- CTEs (WITH clauses) 
- Window functions (RANK OVER PARTITION BY) 
- CASE WHEN statements 
- Aggregates (COUNT, AVG, ROUND) with GROUP BY
- Filtered joins and multi-condition WHERE clauses 