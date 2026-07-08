"""Loads the unused revenue segment and venues data"""

import pandas as pd
from pathlib import Path


def load_segment():
    """Load the unused revenue segment CSV."""
    path = Path(__file__).parent / "data" / "unused_revenue_segment.csv"
    df = pd.read_csv(path)
    return df


def load_venues():
    """Load the NYC venues CSV."""
    path = Path(__file__).parent / "data" / "nyc_venues.csv"
    df = pd.read_csv(path)
    return df