"""HostLens: Airbnb AI-powered recommendations for underperforming Airbnb hosts."""

import streamlit as st
from data_loader import load_segment, load_venues


# Page configuration
st.set_page_config(
    page_title="HostLens",
    page_icon="🏠",
    layout="wide",
)


# HEADER
# ============================================================================

st.markdown(
    """
    <div style='background-color: #FF5A5F; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
        <h1 style='color: white; margin: 0;'>HostLens</h1>
        <p style='color: white; margin: 0; font-size: 16px;'>
            AI-powered recommendations for underperforming Airbnb hosts
        </p>
    </div>
    """,
    unsafe_allow_html=True,
)


# LOAD DATA
# ============================================================================

segment_df = load_segment()
venues_df = load_venues()


# SIDEBAR - LISTING PICKER
# ============================================================================

st.sidebar.title("Choose a listing")
st.sidebar.caption(f"{len(segment_df):,} underperforming listings across NYC")

# Borough filter
borough = st.sidebar.selectbox(
    "Filter by borough",
    options=["All"] + sorted(segment_df["neighbourhood group"].dropna().unique().tolist()),
)

# Apply borough filter
if borough != "All":
    filtered = segment_df[segment_df["neighbourhood group"] == borough]
else:
    filtered = segment_df

# Listing dropdown
filtered = filtered[(filtered['occupancy_proxy'] >= 0.05) & (filtered['occupancy_proxy'] <= 0.45)]

listing_options = [
    f"{row['NAME'][:60]}... — ${int(row['price'])}/night ({int(row['occupancy_proxy']*100)}% booked)"
    for _, row in filtered.head(50).iterrows()
]

selected_option = st.sidebar.selectbox(
    "Pick a listing (top 50 by revenue gap)",
    options=listing_options,
)

# Get the selected listing
selected_idx = listing_options.index(selected_option)
listing = filtered.head(50).iloc[selected_idx]


# MAIN AREA - LISTING DETAILS
# ============================================================================

st.subheader(listing["NAME"])
st.caption(f"{listing['neighbourhood']}, {listing['neighbourhood group']}")

# Metrics row
col1, col2, col3, col4 = st.columns(4)

col1.metric("Rating", f"{listing['review rate number']:.1f} ⭐")
col2.metric("Occupancy", f"{listing['occupancy_proxy'] * 100:.0f}%")
col3.metric("Price/night", f"${int(listing['price'])}")
col4.metric("Revenue gap", f"${int(listing['potential_gain_at_70pct']):,}")

st.markdown("---")


# PLACEHOLDER FOR FEATURES A & B
# ============================================================================

from recommender import generate_recommendations

st.subheader("HostLens Recommendations")
st.caption(
    "AI-generated, prioritized actions this host can take to reduce vacancy. "
    "Recommendations are routed based on review count: hosts with fewer than 50 reviews "
    "receive review-building guidance, hosts with 50+ reviews receive positioning guidance."
)

if st.button("Generate recommendations", type="primary"):
    with st.spinner("HostLens is analyzing this listing..."):
        try:
            recommendations = generate_recommendations(listing)
            recommendations = recommendations.replace("$", "\\$")
            
            # Parse the recommendations into individual items
            # Split by "**1.", "**2.", "**3."
            import re
            parts = re.split(r'\*\*\d+\.', recommendations)
            # First element is empty (before the first "1."), skip it
            items = [p.strip() for p in parts if p.strip()]
            
            # Display each in a styled card
            for i, item in enumerate(items, 1):
                # Remove trailing ** from title
                item = item.strip()
                
                st.markdown(
                    f"""
                    <div style='
                        background-color: white;
                        padding: 20px;
                        border-radius: 12px;
                        border-left: 4px solid #FF5A5F;
                        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                        margin-bottom: 15px;
                    '>
                        <div style='
                            display: inline-block;
                            background-color: #FF5A5F;
                            color: white;
                            padding: 4px 12px;
                            border-radius: 20px;
                            font-size: 12px;
                            font-weight: bold;
                            margin-bottom: 10px;
                        '>PRIORITY {i}</div>
                        <div style='color: #484848; line-height: 1.6;'>{item}</div>
                    </div>
                    """,
                    unsafe_allow_html=True,
                )
                
        except Exception as e:
            st.error(f"Error: {e}")
st.markdown("---")


# ============================================================================
# PLACEHOLDER FOR FEATURE B
# ============================================================================

st.info("**Coming next:** Event-based positioning suggestions (Feature B) and a host-facing dashboard (Feature C).")