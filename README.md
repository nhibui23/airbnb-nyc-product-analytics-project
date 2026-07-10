# Airbnb NYC - HostLens Feasibility Study

**Should Airbnb build an AI recommendation tool for underperforming hosts?**
A product feasibility study by [Nhi Bui](https://linkedin.com/in/nhiuyenbui) · Villanova University

---

## The Premise

Airbnb leadership has proposed HostLens, an AI-powered tool that would give underperforming hosts personalized recommendations to reduce vacancy. Before committing to build, 3 questions need to be answered:

1. Is the target market real and large enough to justify the investment?
2. What actually drives guest booking behavior, and does the recommendation logic have a basis?
3. Does the product prototype feel viable when leadership tries it?

This project answers all 3 questions using a public Kaggle dataset of 63K NYC listings as a proxy for real Airbnb data, then delivers a working prototype for leadership to evaluate.

---

## Key Findings

**On market size (host lens):**

- 6,412 NYC listings hold 5-star ratings but sit at less than 50% occupancy
- Aggregate revenue gap: $735M if the segment lifted to 70% occupancy
- Average opportunity per host: $114,647 per year
- The segment is concentrated in Manhattan (2,615) and Brooklyn (2,405)

**On what drives guest behavior (guest lens):**

- Instant Book has no measurable effect on ratings (p = 0.38)
- Host verification has no measurable effect on ratings (p = 0.91)
- Price tier does affect ratings, with Very High priced listings underperforming (ANOVA p = 0.0008)
- Review count stops meaningfully influencing occupancy after around 50 reviews

**On the routing logic:**

- The 50-review threshold splits the target segment into 76% below (need review-building help) and 24% above (need positioning help)
- Both groups have similar occupancy and price, meaning review count is the meaningful signal for segmentation

---

## The Recommendation

Build HostLens. The market is real ($735M gap in NYC alone), the behavioral drivers are known (price and review count matter, features like Instant Book do not), and the prototype demonstrates a defensible routing logic based on the analysis.

---

## Live Prototype

Try HostLens: https://airbnb-nyc-appuct-analytics-project-qkl8xdb4vwltgjrb2k8ghd.streamlit.app/

The prototype loads a target host, generates personalized recommendations through the Claude API, and routes each host to 1 of 2 recommendation paths based on the 50-review threshold. It also detects nearby NYC venues (Barclays Center, Madison Square Garden, wedding venues) and suggests event-based positioning.

---

## Project Structure

airbnb-nyc-product-analytics-project/
├── data/           # Raw and cleaned Kaggle dataset (proxy for real Airbnb data)
├── notebook/       # Six Jupyter notebooks — the analysis behind the recommendation
├── sql/            # Three operational SQL queries a product team could run to launch
├── powerbi/        # Two-page dashboard: Guest View + Host View
├── prototype/      # Streamlit + Claude API — HostLens working prototype

---

## Tools

Python (pandas, scipy, statsmodels, matplotlib, seaborn) · PostgreSQL · Power BI · Streamlit · Claude API

## Dataset

[Airbnb Open Data on Kaggle](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) - 102,599 NYC listings, cleaned to 63,718. This is used as a proxy dataset since real Airbnb booking data isn't public. Findings should be read as directional patterns rather than exact revenue claims.

## Limitations

- Observational data with no true booking or revenue figures
- Occupancy is estimated as `(365 - availability_365) / 365`
- Ratings in this dataset are nearly uniformly distributed from 2 to 5 stars, which doesn't match real Airbnb data, so findings should be read as directional
- Only 9 listings have > 500 reviews, which limits testing of the review-count analysis
- 179 duplicate listing IDs were detected and handled using distinct counts in Power BI

## What This Project Demonstrates

- Structuring analysis around a specific product decision rather than open-ended exploration
- Using statistical testing (t-tests, ANOVA, Tukey's HSD) to validate product hypotheses
- Designing A/B tests to validate observational findings in production
- Acknowledging dataset limitations while still delivering an actionable recommendation

---

**Nhi Bui** · Villanova University · [LinkedIn](https://linkedin.com/in/nhiuyenbui) · [GitHub](https://github.com/nhibui23)
