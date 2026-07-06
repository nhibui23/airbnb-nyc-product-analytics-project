# Airbnb NYC - A Product Analytics Case Study

**A two-lens analysis of the NYC Airbnb marketplace for a proposal of an Airbnb AI prototype.**

Project by [Nhi Bui](https://linkedin.com/in/nhiuyenbui) · Villanova University

---

## Overview

Airbnb has two customers: guests who book and hosts who list. This project analyzes 63,718 NYC listings from both sides to answer:

1. **Guest lens:** Which listing features actually affect booking behavior?
2. **Host lens:** How much revenue is each listing generating, and which highly-rated hosts show significant vacancy?

Findings are combined into recommendations and an AI-powered prototype that helps underperforming hosts close the gap.

---

## Key findings

- **Instant Book and host verification show no effect on guest ratings.** 2 of the 3 commonly promoted "quality" features are not statistically significant.
- **Very High priced listings underperform.** Rating drops significantly for listings above $1,000/night.
- **Review count matters only up to about 50 reviews.** Past 50 reviews, additional reviews don't improve occupancy.
- **6,412 listings hold a $735M unused revenue gap.** These 5-star listings sit at 19% occupancy, at an average of $620/night.

---

## Project structure 

├── data/           Raw and cleaned Kaggle dataset

├── notebook/       6 Jupyter notebooks (Python analysis)

├── sql/            PostgreSQL queries

├── powerbi/        Two-view dashboard (Guest View + Host View)

├── prototype/      Streamlit app powered by the Claude API

---

## Tools

Python (pandas, scipy, statsmodels, matplotlib, seaborn) · PostgreSQL · Power BI · Streamlit · Claude API

## Dataset

[Airbnb Open Data on Kaggle](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) - 102,599 NYC listings, cleaned to 63,718.

## Limitations

Observational data (no true booking or revenue figures). Occupancy is estimated as `(365 - availability_365) / 365`. Ratings in this dataset are nearly uniformly distributed from 2 to 5 stars, which doesn't match real Airbnb data. Only 9 listings have > 500 reviews, which limits testing at the high end.

## What this project demonstrates

- Framing a business problem from 2 user perspectives instead of 1
- Using statistical testing (t-tests, ANOVA, Tukey's HSD) to serve product decisions
- Translating analysis into an AI prototype launch
- Designing A/B tests to validate hypotheses generated from observational analysis

---

**Nhi Bui** · Villanova University · [LinkedIn](https://linkedin.com/in/nhiuyenbui) · [GitHub](https://github.com/nhibui23)

