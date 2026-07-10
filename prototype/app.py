"""
HostLens — AI-powered recommendations for Airbnb hosts.

Structure of this file:
    1. Imports and page setup
    2. Custom styles (all CSS in one place)
    3. Data loading
    4. Session state setup
    5. Hero section
    6. How it works section
    7. Main tool (listing picker + AI features)
    8. FAQ section
    9. Footer
"""

# ============================================================================
# 1. IMPORTS AND PAGE SETUP
# ============================================================================

import re
import json
import streamlit as st
from data_loader import load_segment, load_venues
from recommender import generate_recommendations
from venue_correlator import find_nearest_venue, generate_positioning

st.set_page_config(
    page_title="HostLens — Fill your calendar",
    page_icon="🏠",
    layout="wide",
)


# ============================================================================
# 2. CUSTOM STYLES
# All custom CSS lives here so it's easy to find and adjust
# ============================================================================

st.markdown("""
<style>
    /* Hide Streamlit default header and footer */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    
    /* Main container spacing */
    .block-container {
        padding-top: 1rem;
        padding-bottom: 2rem;
        max-width: 1100px;
    }
    
    /* Custom button styling */
    .stButton > button {
        background-color: #FF5A5F;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 10px 24px;
        font-weight: 600;
        transition: all 0.2s;
    }
    .stButton > button:hover {
        background-color: #E00007;
        transform: translateY(-1px);
    }
    
    /* Tab styling */
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
    }
    .stTabs [data-baseweb="tab"] {
        border-radius: 8px 8px 0 0;
        padding: 12px 20px;
    }
</style>
""", unsafe_allow_html=True)


# ============================================================================
# 3. DATA LOADING
# ============================================================================

segment_df = load_segment()
venues_df = load_venues()


# ============================================================================
# 4. SESSION STATE SETUP
# Tracks the current listing and cached AI responses
# ============================================================================

if 'recommendations' not in st.session_state:
    st.session_state.recommendations = None
if 'positioning' not in st.session_state:
    st.session_state.positioning = None
if 'last_listing_id' not in st.session_state:
    st.session_state.last_listing_id = None


# ============================================================================
# 5. HERO SECTION
# Introduces the product with a warm, direct-to-user headline
# ============================================================================

st.markdown("""
<div style='
    background: linear-gradient(135deg, #FF5A5F 0%, #FC642D 100%);
    padding: 60px 40px;
    border-radius: 20px;
    margin-bottom: 40px;
    color: white;
    text-align: center;
'>
    <div style='font-size: 14px; font-weight: 700; letter-spacing: 2px; margin-bottom: 12px; opacity: 0.9;'>
        HOSTLENS
    </div>
    <h1 style='font-size: 44px; font-weight: 700; margin: 0 0 16px 0; line-height: 1.2;'>
        Your listing is sitting empty.<br>Let's fix that.
    </h1>
    <p style='font-size: 18px; margin: 0; opacity: 0.95; max-width: 700px; margin-left: auto; margin-right: auto;'>
        AI-powered recommendations to help highly-rated NYC hosts turn empty nights into bookings.
    </p>
</div>
""", unsafe_allow_html=True)


# ============================================================================
# 6. HOW IT WORKS SECTION
# Three simple steps showing what the user does
# ============================================================================

st.markdown("""
<div style='margin-bottom: 40px;'>
    <h2 style='color: #222; font-size: 28px; font-weight: 700; text-align: center; margin-bottom: 32px;'>
        How HostLens works
    </h2>
    <div style='display: flex; gap: 20px; justify-content: space-between;'>
        <div style='flex: 1; background: white; padding: 28px; border-radius: 16px; border: 1px solid #eee; text-align: center;'>
            <div style='font-size: 40px; margin-bottom: 12px;'>🏠</div>
            <div style='color: #FF5A5F; font-weight: 700; font-size: 14px; margin-bottom: 8px;'>STEP 1</div>
            <div style='color: #222; font-weight: 600; font-size: 18px; margin-bottom: 8px;'>Pick your listing</div>
            <div style='color: #767676; font-size: 14px; line-height: 1.5;'>
                Choose from 6,300+ highly-rated NYC listings with low occupancy
            </div>
        </div>
        <div style='flex: 1; background: white; padding: 28px; border-radius: 16px; border: 1px solid #eee; text-align: center;'>
            <div style='font-size: 40px; margin-bottom: 12px;'>✨</div>
            <div style='color: #FF5A5F; font-weight: 700; font-size: 14px; margin-bottom: 8px;'>STEP 2</div>
            <div style='color: #222; font-weight: 600; font-size: 18px; margin-bottom: 8px;'>Get AI recommendations</div>
            <div style='color: #767676; font-size: 14px; line-height: 1.5;'>
                Personalized actions based on your listing's specific data
            </div>
        </div>
        <div style='flex: 1; background: white; padding: 28px; border-radius: 16px; border: 1px solid #eee; text-align: center;'>
            <div style='font-size: 40px; margin-bottom: 12px;'>📈</div>
            <div style='color: #FF5A5F; font-weight: 700; font-size: 14px; margin-bottom: 8px;'>STEP 3</div>
            <div style='color: #222; font-weight: 600; font-size: 18px; margin-bottom: 8px;'>Boost your revenue</div>
            <div style='color: #767676; font-size: 14px; line-height: 1.5;'>
                Close the gap between empty nights and full occupancy
            </div>
        </div>
    </div>
</div>
""", unsafe_allow_html=True)

st.markdown("---")


# ============================================================================
# 7. MAIN TOOL — LISTING PICKER + AI FEATURES
# ============================================================================

st.markdown("""
<h2 style='color: #222; font-size: 28px; font-weight: 700; margin-bottom: 8px;'>
    Try it with a real listing
</h2>
<p style='color: #767676; font-size: 16px; margin-bottom: 24px;'>
    Select a borough and a listing to see personalized recommendations.
</p>
""", unsafe_allow_html=True)

# ----- Listing picker in the main area (not sidebar) -----

col_a, col_b = st.columns([1, 3])

with col_a:
    borough = st.selectbox(
        "Borough",
        options=["All"] + sorted(segment_df["neighbourhood group"].dropna().unique().tolist()),
    )

# Filter data based on borough
if borough != "All":
    filtered = segment_df[segment_df["neighbourhood group"] == borough]
else:
    filtered = segment_df

# Only show listings with some occupancy variety (not 0% empties)
filtered = filtered[(filtered["occupancy_proxy"] >= 0.05) & (filtered["occupancy_proxy"] <= 0.45)]

# Build the dropdown options
listing_options = [
    f"{row['NAME'][:60]} — ${int(row['price'])}/night ({int(row['occupancy_proxy']*100)}% booked)"
    for _, row in filtered.head(50).iterrows()
]

with col_b:
    selected_option = st.selectbox(
        "Listing",
        options=listing_options,
    )

# Grab the selected listing's data
selected_idx = listing_options.index(selected_option)
listing = filtered.head(50).iloc[selected_idx]

# Reset cached AI responses if the user picked a new listing
if st.session_state.last_listing_id != listing.get('id'):
    st.session_state.recommendations = None
    st.session_state.positioning = None
    st.session_state.last_listing_id = listing.get('id')


# ----- Listing details card -----

st.markdown(f"""
<div style='background: white; padding: 24px 28px; border-radius: 16px; border: 1px solid #eee; margin: 20px 0;'>
    <div style='color: #767676; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 8px;'>
        Selected listing
    </div>
    <h3 style='color: #222; font-size: 22px; font-weight: 700; margin: 0 0 4px 0;'>
        {listing["NAME"]}
    </h3>
    <p style='color: #767676; font-size: 14px; margin: 0 0 20px 0;'>
        {listing["neighbourhood"]}, {listing["neighbourhood group"]}
    </p>
    <div style='display: flex; gap: 32px;'>
        <div>
            <div style='color: #767676; font-size: 12px; text-transform: uppercase;'>Rating</div>
            <div style='color: #222; font-size: 22px; font-weight: 700;'>{listing["review rate number"]:.1f} ⭐</div>
        </div>
        <div>
            <div style='color: #767676; font-size: 12px; text-transform: uppercase;'>Occupancy</div>
            <div style='color: #222; font-size: 22px; font-weight: 700;'>{listing["occupancy_proxy"] * 100:.0f}%</div>
        </div>
        <div>
            <div style='color: #767676; font-size: 12px; text-transform: uppercase;'>Price/night</div>
            <div style='color: #222; font-size: 22px; font-weight: 700;'>${int(listing["price"])}</div>
        </div>
        <div>
            <div style='color: #767676; font-size: 12px; text-transform: uppercase;'>Revenue gap</div>
            <div style='color: #FF5A5F; font-size: 22px; font-weight: 700;'>${int(listing["potential_gain_at_70pct"]):,}</div>
        </div>
    </div>
</div>
""", unsafe_allow_html=True)


# ----- AI feature tabs -----

tab1, tab2 = st.tabs(["🎯 Vacancy Recommendations", "📍 Event & Venue Positioning"])


# ----- TAB 1: Vacancy Recommendations -----

with tab1:
    st.markdown("""
    <p style='color: #767676; font-size: 14px; margin: 12px 0;'>
        AI-generated actions prioritized by impact. Hosts under 50 reviews get review-building guidance; hosts above 50 get positioning guidance.
    </p>
    """, unsafe_allow_html=True)

    if st.button("Generate recommendations", type="primary", key="rec_btn"):
        with st.spinner("HostLens is analyzing this listing..."):
            try:
                st.session_state.recommendations = generate_recommendations(listing)
            except Exception as e:
                st.error(f"Error: {e}")

    if st.session_state.recommendations:
        raw = st.session_state.recommendations.strip()
        # Strip any code fences Claude might add
        raw = re.sub(r'^```json\s*|\s*```$', '', raw).strip()
        raw = re.sub(r'^```\s*|\s*```$', '', raw).strip()

        try:
            recs = json.loads(raw)
        except Exception:
            st.error("Could not parse recommendations. Try regenerating.")
            recs = []

        priority_labels = ["HIGHEST IMPACT", "MEDIUM IMPACT", "QUICK WIN"]
        priority_colors = ["#FF5A5F", "#FC642D", "#00A699"]

        for i, rec in enumerate(recs):
            title = rec.get("title", "")
            action = rec.get("action", "")
            why = rec.get("why", "")
            color = priority_colors[i] if i < len(priority_colors) else "#FF5A5F"
            label = priority_labels[i] if i < len(priority_labels) else f"PRIORITY {i+1}"

            card = f"<div style='background: linear-gradient(135deg, #ffffff 0%, #fafafa 100%); padding: 24px 28px; border-radius: 16px; border: 1px solid #eeeeee; box-shadow: 0 4px 16px rgba(0,0,0,0.04); margin-bottom: 18px; position: relative; overflow: hidden;'><div style='position: absolute; top: 0; left: 0; width: 5px; height: 100%; background: {color};'></div><div style='display: flex; align-items: center; margin-bottom: 16px;'><div style='background-color: {color}; color: white; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 15px; margin-right: 12px;'>{i+1}</div><div><div style='color: {color}; font-size: 10px; font-weight: 700; letter-spacing: 1px;'>{label}</div><div style='color: #222222; font-size: 17px; font-weight: 600;'>{title}</div></div></div><div style='margin-left: 44px;'><div style='margin-bottom: 12px;'><span style='color: {color}; font-weight: 600; font-size: 12px; letter-spacing: 0.5px;'>→ ACTION</span><div style='color: #484848; font-size: 15px; line-height: 1.5; margin-top: 3px;'>{action}</div></div><div><span style='color: #999999; font-weight: 600; font-size: 12px; letter-spacing: 0.5px;'>WHY IT WORKS</span><div style='color: #767676; font-size: 14px; line-height: 1.5; margin-top: 3px;'>{why}</div></div></div></div>"
            st.markdown(card, unsafe_allow_html=True)


# ----- TAB 2: Event & Venue Positioning -----

with tab2:
    st.markdown("""
    <p style='color: #767676; font-size: 14px; margin: 12px 0;'>
        Detects nearby NYC venues (concerts, weddings, sports, business) and suggests how to reposition the listing.
    </p>
    """, unsafe_allow_html=True)

    nearest_venue = find_nearest_venue(listing)

    if nearest_venue is None:
        st.info("No major venues within 1.5 miles of this listing.")
    else:
        st.markdown(f"""
        <div style='background-color: #FFF9F5; padding: 16px 22px; border-radius: 12px; border-left: 4px solid #FC642D; margin-bottom: 16px;'>
            <div style='color: #767676; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;'>Nearest Venue</div>
            <div style='color: #484848; font-size: 18px; font-weight: 600;'>{nearest_venue['venue_name']}</div>
            <div style='color: #767676; font-size: 14px; margin-top: 4px;'>
                {nearest_venue['venue_type']} · <strong>{nearest_venue['distance_mi']:.2f} miles away</strong>
            </div>
        </div>
        """, unsafe_allow_html=True)

        if st.button("Generate positioning suggestions", type="primary", key="venue_btn"):
            with st.spinner("HostLens is analyzing venue proximity..."):
                try:
                    st.session_state.positioning = generate_positioning(listing, nearest_venue)
                except Exception as e:
                    st.error(f"Error: {e}")

        if st.session_state.positioning:
            raw = st.session_state.positioning.strip()
            raw = re.sub(r'^```json\s*|\s*```$', '', raw).strip()
            raw = re.sub(r'^```\s*|\s*```$', '', raw).strip()

            try:
                pos = json.loads(raw)
            except Exception:
                st.error("Could not parse suggestions. Try regenerating.")
                pos = {}

            new_name = pos.get("listing_name", "")
            description = pos.get("description", "")
            amenities = pos.get("amenities", [])

            amenities_html = ""
            for amenity in amenities:
                amenities_html += f"<div style='display: flex; align-items: flex-start; margin-bottom: 8px;'><span style='color: #FC642D; margin-right: 10px; font-size: 16px;'>✦</span><span style='color: #484848; font-size: 15px; line-height: 1.4;'>{amenity}</span></div>"

            card = f"<div style='background: linear-gradient(135deg, #ffffff 0%, #fffaf7 100%); padding: 26px 30px; border-radius: 16px; border: 1px solid #f5e6dc; box-shadow: 0 4px 16px rgba(0,0,0,0.04);'><div style='margin-bottom: 20px;'><div style='color: #FC642D; font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 6px;'>SUGGESTED LISTING NAME</div><div style='color: #222222; font-size: 20px; font-weight: 700; line-height: 1.3;'>{new_name}</div></div><div style='margin-bottom: 20px;'><div style='color: #FC642D; font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 6px;'>DESCRIPTION ANGLE</div><div style='color: #484848; font-size: 15px; line-height: 1.6;'>{description}</div></div><div><div style='color: #FC642D; font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 10px;'>RECOMMENDED AMENITIES</div>{amenities_html}</div></div>"
            st.markdown(card, unsafe_allow_html=True)


# ============================================================================
# 8. FAQ SECTION
# Uses Streamlit's built-in expander for collapsible questions
# ============================================================================

st.markdown("---")
st.markdown("""
<h2 style='color: #222; font-size: 28px; font-weight: 700; margin: 40px 0 24px 0;'>
    Questions you might have
</h2>
""", unsafe_allow_html=True)

with st.expander("What is HostLens?"):
    st.write(
        "HostLens is an AI-powered assistant that helps highly-rated Airbnb hosts in NYC "
        "reduce vacancy. It analyzes each listing's data and generates specific, "
        "prioritized recommendations to help hosts increase occupancy."
    )

with st.expander("How does HostLens fit Airbnb's mission?"):
    st.write(
        "Airbnb's mission is to help people belong anywhere. But that only works if hosts "
        "can sustain their listings. Today, thousands of highly-rated NYC hosts are "
        "underperforming despite offering great stays — sitting at 19% occupancy at "
        "an average of $620/night. That's $735M of unused revenue in NYC alone. "
        "HostLens gives these hosts AI-driven guidance to close the gap. More successful "
        "hosts means more available stays for guests, and a stronger marketplace overall."
    )

with st.expander("How does the AI work?"):
    st.write(
        "HostLens uses Anthropic's Claude API. When you click 'Generate recommendations', "
        "the app sends the listing's metrics — price, rating, review count, occupancy, "
        "revenue gap — to Claude along with a carefully designed prompt. The routing "
        "logic is important: hosts with fewer than 50 reviews receive review-building "
        "guidance, while hosts above 50 reviews receive positioning guidance. This "
        "threshold came from statistical analysis of 63K NYC listings, which showed "
        "that occupancy stops improving after ~50 reviews."
    )

with st.expander("Where does the data come from?"):
    st.write(
        "HostLens uses a public Airbnb dataset of 102,599 NYC listings from Kaggle, "
        "cleaned down to 63,718 valid rows. The 'unused revenue segment' — the target "
        "group HostLens serves — was identified through statistical analysis, filtering "
        "to listings with 4.5+ star ratings but less than 50% occupancy. "
        "Note: this is observational data, not real-time bookings. Occupancy is "
        "estimated using an availability-based proxy."
    )

with st.expander("Is this a real Airbnb product?"):
    st.write(
        "No. HostLens is a portfolio product prototype built to demonstrate how "
        "marketplace analytics can be translated into individual host-level "
        "recommendations using AI. It's a proof of concept, not a shipping Airbnb feature."
    )

with st.expander("Who built this?"):
    st.markdown(
        "HostLens was built by **Nhi Bui**, a student at Villanova University. "
        "The full project — including the analysis, SQL, and Power BI dashboard — "
        "is on [GitHub](https://github.com/nhibui23/airbnb-nyc-product-analytics-project). "
        "You can also find her on [LinkedIn](https://linkedin.com/in/nhiuyenbui)."
    )


# ============================================================================
# 9. FOOTER
# ============================================================================

st.markdown("---")
st.markdown("""
<div style='text-align: center; padding: 24px 0; color: #767676; font-size: 13px;'>
    HostLens · A portfolio product analytics case study<br>
    Built with Streamlit + Anthropic Claude API<br>
    <strong>Nhi Bui</strong> · Villanova University
</div>
""", unsafe_allow_html=True)