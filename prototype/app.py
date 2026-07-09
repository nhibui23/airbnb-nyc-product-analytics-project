"""HostLens — AI-powered recommendations for underperforming Airbnb hosts."""

import re
import streamlit as st
from data_loader import load_segment, load_venues


# Page configuration
st.set_page_config(
    page_title="HostLens",
    page_icon="🏠",
    layout="wide",
)


# ============================================================================
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


# ============================================================================
# LOAD DATA
# ============================================================================

segment_df = load_segment()
venues_df = load_venues()


# ============================================================================
# SIDEBAR - LISTING PICKER
# ============================================================================

st.sidebar.title("Choose a listing")
st.sidebar.caption(f"{len(segment_df):,} underperforming listings across NYC")

borough = st.sidebar.selectbox(
    "Filter by borough",
    options=["All"] + sorted(segment_df["neighbourhood group"].dropna().unique().tolist()),
)

if borough != "All":
    filtered = segment_df[segment_df["neighbourhood group"] == borough]
else:
    filtered = segment_df

# Filter to listings with some occupancy variety
filtered = filtered[(filtered["occupancy_proxy"] >= 0.05) & (filtered["occupancy_proxy"] <= 0.45)]

listing_options = [
    f"{row['NAME'][:60]} — ${int(row['price'])}/night ({int(row['occupancy_proxy']*100)}% booked)"
    for _, row in filtered.head(50).iterrows()
]

selected_option = st.sidebar.selectbox(
    "Pick a listing (top 50 by revenue gap)",
    options=listing_options,
)

selected_idx = listing_options.index(selected_option)
listing = filtered.head(50).iloc[selected_idx]


# ============================================================================
# MAIN AREA - LISTING DETAILS
# ============================================================================

st.subheader(listing["NAME"])
st.caption(f"{listing['neighbourhood']}, {listing['neighbourhood group']}")

col1, col2, col3, col4 = st.columns(4)
col1.metric("Rating", f"{listing['review rate number']:.1f} ⭐")
col2.metric("Occupancy", f"{listing['occupancy_proxy'] * 100:.0f}%")
col3.metric("Price/night", f"${int(listing['price'])}")
col4.metric("Revenue gap", f"${int(listing['potential_gain_at_70pct']):,}")

st.markdown("---")


# ============================================================================
# HELPER: Convert markdown to HTML for inline rendering
# ============================================================================

def md_to_html(text):
    """Convert basic markdown to HTML for inline display in styled divs."""
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    lines = text.split('\n')
    html_lines = []
    in_list = False
    for line in lines:
        line = line.strip()
        if line.startswith('- '):
            if not in_list:
                html_lines.append('<ul style="margin: 8px 0; padding-left: 20px;">')
                in_list = True
            html_lines.append(f'<li style="margin: 4px 0;">{line[2:]}</li>')
        else:
            if in_list:
                html_lines.append('</ul>')
                in_list = False
            if line:
                html_lines.append(f'<p style="margin: 8px 0;">{line}</p>')
    if in_list:
        html_lines.append('</ul>')
    return '\n'.join(html_lines)


# ============================================================================
# INITIALIZE SESSION STATE
# ============================================================================

if 'recommendations' not in st.session_state:
    st.session_state.recommendations = None
if 'positioning' not in st.session_state:
    st.session_state.positioning = None
if 'last_listing_id' not in st.session_state:
    st.session_state.last_listing_id = None

if st.session_state.last_listing_id != listing.get('id'):
    st.session_state.recommendations = None
    st.session_state.positioning = None
    st.session_state.last_listing_id = listing.get('id')


# ============================================================================
# TABS FOR FEATURE A AND FEATURE B
# ============================================================================

tab1, tab2 = st.tabs(["🎯 Vacancy Recommendations", "📍 Event & Venue Positioning"])


# ============================================================================
# TAB 1: FEATURE A — VACANCY RECOMMENDATIONS
# ============================================================================

with tab1:
    from recommender import generate_recommendations

    st.markdown(
        """
        <div style='padding: 12px 0 8px 0;'>
            <p style='color: #767676; font-size: 14px; margin: 0;'>
                AI-generated actions prioritized by impact. Recommendations are routed based on the host's review count.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    if st.button("Generate recommendations", type="primary", key="rec_btn"):
        with st.spinner("HostLens is analyzing this listing..."):
            try:
                st.session_state.recommendations = generate_recommendations(listing)
            except Exception as e:
                st.error(f"Error: {e}")

    if st.session_state.recommendations:
        import json
        
        raw = st.session_state.recommendations.strip()
        # Remove markdown code fences if present
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
            title = rec.get("title", "").replace("$", "\\$")
            action = rec.get("action", "").replace("$", "\\$")
            why = rec.get("why", "").replace("$", "\\$")
            
            color = priority_colors[i] if i < len(priority_colors) else "#FF5A5F"
            label = priority_labels[i] if i < len(priority_labels) else f"PRIORITY {i+1}"
            
            st.markdown(
                f"""
                <div style='
                    background: linear-gradient(135deg, #ffffff 0%, #fafafa 100%);
                    padding: 24px 28px;
                    border-radius: 16px;
                    border: 1px solid #eeeeee;
                    box-shadow: 0 4px 16px rgba(0,0,0,0.04);
                    margin-bottom: 18px;
                    position: relative;
                    overflow: hidden;
                '>
                    <div style='position: absolute; top: 0; left: 0; width: 5px; height: 100%; background: {color};'></div>
                    <div style='display: flex; align-items: center; margin-bottom: 16px;'>
                        <div style='
                            background-color: {color}; color: white; width: 32px; height: 32px;
                            border-radius: 50%; display: flex; align-items: center; justify-content: center;
                            font-weight: 700; font-size: 15px; margin-right: 12px; flex-shrink: 0;
                        '>{i+1}</div>
                        <div>
                            <div style='color: {color}; font-size: 10px; font-weight: 700; letter-spacing: 1px;'>{label}</div>
                            <div style='color: #222222; font-size: 17px; font-weight: 600;'>{title}</div>
                        </div>
                    </div>
                    <div style='margin-left: 44px;'>
                        <div style='margin-bottom: 12px;'>
                            <span style='color: {color}; font-weight: 600; font-size: 12px; letter-spacing: 0.5px;'>→ ACTION</span>
                            <div style='color: #484848; font-size: 15px; line-height: 1.5; margin-top: 3px;'>{action}</div>
                        </div>
                        <div>
                            <span style='color: #999999; font-weight: 600; font-size: 12px; letter-spacing: 0.5px;'>WHY IT WORKS</span>
                            <div style='color: #767676; font-size: 14px; line-height: 1.5; margin-top: 3px;'>{why}</div>
                        </div>
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )

# ============================================================================
# TAB 2: FEATURE B — EVENT & VENUE CORRELATION
# ============================================================================

with tab2:
    from venue_correlator import find_nearest_venue, generate_positioning

    st.markdown(
        """
        <div style='padding: 12px 0 8px 0;'>
            <p style='color: #767676; font-size: 14px; margin: 0;'>
                Detects nearby NYC venues and generates positioning suggestions to attract event-based guests.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    nearest_venue = find_nearest_venue(listing)

    if nearest_venue is None:
        st.markdown(
            """
            <div style='
                background-color: #F5F5F5;
                padding: 20px;
                border-radius: 12px;
                text-align: center;
                color: #767676;
            '>
                <strong>No major venues within 1.5 miles.</strong><br>
                <span style='font-size: 13px;'>Event-based positioning is not available for this listing.</span>
            </div>
            """,
            unsafe_allow_html=True,
        )
    else:
        st.markdown(
            f"""
            <div style='
                background-color: #FFF9F5;
                padding: 16px 22px;
                border-radius: 12px;
                border-left: 4px solid #FC642D;
                margin-bottom: 16px;
            '>
                <div style='color: #767676; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;'>Nearest Venue</div>
                <div style='color: #484848; font-size: 18px; font-weight: 600;'>{nearest_venue['venue_name']}</div>
                <div style='color: #767676; font-size: 14px; margin-top: 4px;'>
                    {nearest_venue['venue_type']} · <strong>{nearest_venue['distance_mi']:.2f} miles away</strong>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        if st.button("Generate positioning suggestions", type="primary", key="venue_btn"):
            with st.spinner("HostLens is analyzing venue proximity..."):
                try:
                    st.session_state.positioning = generate_positioning(listing, nearest_venue)
                except Exception as e:
                    st.error(f"Error: {e}")

        if st.session_state.positioning:
            positioning = st.session_state.positioning.replace("$", "\\$")
            positioning_html = md_to_html(positioning)

            st.markdown(
                f"""
                <div style='
                    background-color: white;
                    padding: 22px 26px;
                    border-radius: 12px;
                    border-left: 4px solid #FC642D;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
                '>
                    <div style='color: #484848; line-height: 1.7; font-size: 15px;'>
                        {positioning_html}
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )