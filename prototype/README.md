# HostLens Prototype

A Streamlit web app that identifies underperforming Airbnb hosts and generates personalized AI recommendations to reduce vacancy.

## Live demo

https://airbnb-nyc-appuct-analytics-project-qkl8xdb4vwltgjrb2k8ghd.streamlit.app/

## How it works

1. User picks a host from the target segment (6,412 highly-rated NYC listings with less than 50% occupancy)
2. HostLens sends the listing's metrics to the Claude API with a structured prompt
3. Claude returns 3 prioritized recommendations, routed based on a 50-review threshold from the underlying statistical analysis
4. A second feature detects nearby NYC venues (Barclays, MSG, wedding venues) and generates event-based positioning suggestions

## Run locally

1. Install requirements: `pip install -r requirements.txt`
2. Add your Claude API key to `.env`: `ANTHROPIC_API_KEY=sk-ant-...`
3. Run: `streamlit run app.py`

## Files

- `app.py`: main Streamlit app
- `recommender.py`: Feature A: vacancy recommendation logic
- `venue_correlator.py`: Feature B: venue matching + positioning
- `data_loader.py`: CSV loaders for the target segment and venue data
- `prompts/`: Claude prompt templates
- `data/`: target segment CSV and NYC venue reference data