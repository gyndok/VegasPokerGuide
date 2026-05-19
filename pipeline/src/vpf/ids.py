import re
from datetime import date as _date


def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")


def tournament_id(venue_slug: str, d: _date, event_name: str) -> str:
    return f"{_slugify(venue_slug)}-{d.isoformat()}-{_slugify(event_name)}"
