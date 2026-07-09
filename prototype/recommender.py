"""Host Lens - generates AI recommendations to reduce host vacancy."""

import os
from pathlib import Path
from anthropic import Anthropic
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


def get_client():
    """Initialize the Claude API client."""
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise ValueError(
            "ANTHROPIC_API_KEY not found. Make sure you have a .env file "
            "with your API key in the prototype/ folder."
        )
    return Anthropic(api_key=api_key)


def get_context(listing):
    """Return context based on the host's review count."""
    reviews = listing.get("number of reviews", 0)
    if reviews < 50:
        return (
            f"This host has only {int(reviews)} reviews. Based on our analysis of 63K NYC listings, "
            "hosts under 50 reviews should focus on building their review count "
            "because occupancy rises significantly in this range. "
            "Prioritize recommendations that help them get more bookings and reviews quickly."
        )
    else:
        return (
            f"This host has {int(reviews)} reviews, which is past the 50-review threshold where "
            "additional reviews stop meaningfully affecting occupancy. "
            "Prioritize recommendations around positioning, pricing, and event-based demand capture "
            "rather than chasing more reviews."
        )


def build_prompt(listing):
    """Build the prompt by filling in listing details."""
    prompt_path = Path(__file__).parent / "prompts" / "recommender_prompt.txt"
    template = prompt_path.read_text()
    
    occupancy_pct = int(listing["occupancy_proxy"] * 100)
    potential_revenue = int(0.70 * listing["price"] * 365)
    revenue_gap = int(listing["potential_gain_at_70pct"])
    
    return template.format(
        name=listing["NAME"],
        neighbourhood=listing["neighbourhood"],
        neighbourhood_group=listing["neighbourhood group"],
        price=int(listing["price"]),
        rating=listing["review rate number"],
        number_of_reviews=int(listing["number of reviews"]),
        occupancy_pct=occupancy_pct,
        estimated_revenue=int(listing["estimated_revenue"]),
        potential_revenue=potential_revenue,
        revenue_gap=revenue_gap,
        context=get_context(listing),
    )


def generate_recommendations(listing):
    """Generate 3 vacancy-reduction recommendations using Claude."""
    client = get_client()
    prompt = build_prompt(listing)
    
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )
    
    return message.content[0].text