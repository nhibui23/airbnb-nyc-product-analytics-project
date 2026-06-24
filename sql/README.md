# AirBnB NYC Analytics Project - SQL Analysis

* Project by Nhi Bui · Villanova University · [GitHub](https://github.com/nhibui23/airbnb-saas-product-analytics) · [LinkedIn](https://linkedin.com/in/nhiuyenbui)


 This file extends the Python analysis (notebooks 02-06) by answering follow-up questions that emerged from the EDA and statistical testing. 

## Files

| File | Purpose |
|---|---|
| `01_schema.sql` | Creates the `listings` table and loads the cleaned dataset (63,718 rows) into PostgreSQL |
| `02_analysis.sql` | 13 analytical queries to follow up on 3 business questions |


## Business Questions 

**Q1. Which factors actually drive review ratings?**
* The Python ANOVA showed availability, price, and minimum nights matter

* SQL goes further: at what price should a host actually charge, what's the ideal listing setup, and at what point does adding more availability stop helping?

**Q2. Does Instant Book really not matter?**
* The Python A/B test said no impact overal, but maybe it works in some boroughs but not others, or for budget listings but not premium one

* SQL will segment to check the effect across different groups

**Q3. Where should Airbnb grow, and how?**
* Python suggested Airbnb grow in the Bronx

* SQL follows up with details: what does the Bronx market actually look like, where are the supply gaps, and what should a new host in Mott Haven or Belmont actually price their listing at?

## SQL Techniques Used

- CTEs (WITH clauses) for organizing multi-step queries
- Subqueries for filtering and aggregation
- CASE WHEN statements for grouping prices, availability, and stay lengths into tiers
- JOINs for combining data across boroughs
- Aggregates (COUNT, SUM, AVG, MIN, MAX) with GROUP BY and HAVING
- Conditional counting using SUM(CASE WHEN...) for adoption rates