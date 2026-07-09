"""Venue Correlator - matches listings to nearby NYC venues for themed positioning."""

import os
import math
from pathlib import Path
from anthropic import Anthropic
from dotenv import load_dotenv
from data_loader import load_venues

load_dotenv()


def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two lat/long points in miles."""
    R = 3958.8  # Earth's radius in miles
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    return R * c


def find_nearest_venue(listing, max_distance_mi=1.5):
    """Find the closest venue to a listing within max_distance_mi."""
    venues = load_venues()
    listing_lat = listing["lat"]
    listing_long = listing["long"]
    
    venues["distance_mi"] = venues.apply(
        lambda v: haversine_distance(listing_lat, listing_long, v["lat"], v["long"]),
        axis=1
    )
    
    nearby = venues[venues["distance_mi"] <= max_distance_mi].sort_values("distance_mi")
    
    if nearby.empty:
        return None
    
    return nearby.iloc[0]


def generate_positioning(listing, venue):
    """Generate positioning suggestions based on nearby venue."""
    api_key = os.getenv("ANTHROPIC_API_KEY")
    client = Anthropic(api_key=api_key)
    
    prompt_path = Path(__file__).parent / "prompts" / "event_prompt.txt"
    template = prompt_path.read_text()
    
    prompt = template.format(
        name=listing["NAME"],
        neighbourhood=listing["neighbourhood"],
        neighbourhood_group=listing["neighbourhood group"],
        price=int(listing["price"]),
        rating=listing["review rate number"],
        venue_name=venue["venue_name"],
        venue_type=venue["venue_type"],
        distance_mi=f"{venue['distance_mi']:.2f}",
    )
    
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )
    
    return message.content[0].text