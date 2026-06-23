# Airbnb NYC Product Analytics

*Where Airbnb should expand, what new hosts should build, and which features to deprioritize.*

**You're a Product Analyst at Airbnb. The growth team has one question:**  
**Where should we invest next, and what should a new host in that market do to succeed?**

I analyzed 63,718 NYC listings across 5 boroughs to answer it.

## Results at a Glance
- **Availability** is the #1 driver of review ratings (ANOVA p < 0.0001)
- **Instant Book** has no measurable impact on engagement (p = 0.38)
- **The Bronx** is the clearest growth opportunity — highest ratings, lowest supply

## Key Findings

**What matters:**
- Availability is the strongest predictor of review ratings
- Monthly stays (8–30 nights) outperform shorter stays (p = 0.0001)
- Listings over $1000 rate significantly lower than mid-range (p = 0.0004)

**What doesn't:**
- Instant Book has no significant effect (p = 0.38, Cohen's d = 0.007)
- Host identity verification has nearly no effect (p = 0.62)

**Where to grow:**
- The Bronx: highest average rating (3.36), lowest supply (2,049 listings)
- Top neighborhoods: Mott Haven, Schuylerville, Belmont

## Product Recommendations
1. Build a pricing guidance tool to prevent overpricing
2. Promote monthly stays as a premium tier
3. Encourage hosts to schedule maintenance breaks
4. Focus host acquisition in Bronx neighborhoods (Mott Haven, Schuylerville, Belmont)
5. Shift resources away from Instant Book

## Future Data Needed
- **Booking volume** data to measure actual demand
- **Time-series data** to validate whether recommendations improve outcomes
- **Listing photo and description quality** for potential maintenance suggestions
- **Guest demographics** to understand rating behavior across traveler types
- **Competitor pricing** data to build the recommended pricing tool

---

## Dataset
[Airbnb Open Data](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) — 102,599 NYC listings, cleaned to 63,718 across 21 columns.

## Tools
**Python** (pandas, numpy, matplotlib, seaborn, scipy, statsmodels) · **PostgreSQL** · **Power BI** · **Claude API**

## Project Structure
├── data/

├── notebook/

│   ├── 01_data_prep.ipynb         

│   ├── 02_eda.ipynb               

│   ├── 03_ab_testing.ipynb       

│   ├── 04_location_analysis.ipynb 

│   ├── 05_statistical_testing.ipynb 

│   └── 06_final_conclusion.ipynb  

├── sql/                           

└── requirements.txt

## Limitations
Snapshot data only · No booking/revenue data · 1–5 rating scale limits sensitivity · Findings are correlational, not causal · NYC-specific

---

**Nhi Bui** - Villanova University  
[LinkedIn](https://linkedin.com/in/nhiuyenbui) · [GitHub](https://github.com/nhibui23)
