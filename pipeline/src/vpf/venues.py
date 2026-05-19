from openpyxl.worksheet.worksheet import Worksheet
from pathlib import Path
from typing import Optional
import yaml


def extract_schedule_hyperlinks(ws: Worksheet) -> list[str]:
    """Walk every cell of the Schedule tab and collect external hyperlink targets."""
    urls: list[str] = []
    seen: set[str] = set()
    for row in ws.iter_rows():
        for cell in row:
            link = cell.hyperlink
            if link and link.target and link.target.startswith("http"):
                if link.target not in seen:
                    seen.add(link.target)
                    urls.append(link.target)
    return urls


def load_venues(yaml_path: Path) -> list[dict]:
    with open(yaml_path, "r") as f:
        return yaml.safe_load(f) or []


def slug_for_venue_display(display: str, venues: list[dict]) -> Optional[str]:
    """Match a sheet venue string to a curated slug via case-insensitive 'match_terms' lookup."""
    if not display:
        return None
    haystack = display.upper()
    for v in venues:
        for term in v.get("match_terms", []):
            if term.upper() in haystack:
                return v["slug"]
    return None
