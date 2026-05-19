from openpyxl import load_workbook
from pathlib import Path
import pytest
from vpf.venues import extract_schedule_hyperlinks, load_venues, slug_for_venue_display


def test_extracts_pdf_urls(sheet_xlsx):
    wb = load_workbook(sheet_xlsx)  # NOT data_only — preserve hyperlinks
    urls = extract_schedule_hyperlinks(wb["Schedule 2026"])
    # urls is a set of absolute URLs
    assert any("venetianlasvegas.com" in u for u in urls)
    assert any("wynnresorts.com" in u for u in urls)
    assert any("wsop.gg-global-cdn.com" in u for u in urls)
    assert any("southpointcasino.com" in u for u in urls)


def test_urls_are_unique(sheet_xlsx):
    wb = load_workbook(sheet_xlsx)
    urls = extract_schedule_hyperlinks(wb["Schedule 2026"])
    assert len(urls) == len(set(urls))


VENUES_YML = Path(__file__).parent.parent / "venues.yml"


def test_load_venues_returns_eight():
    venues = load_venues(VENUES_YML)
    assert len(venues) == 8
    slugs = {v["slug"] for v in venues}
    assert {"wsop-paris", "wynn", "venetian", "aria", "mgm-grand", "orleans", "south-point", "golden-nugget"} == slugs


@pytest.mark.parametrize("display,expected", [
    ("Venetian", "venetian"),
    ("Wynn", "wynn"),
    ("WSOP Paris/Horseshoe", "wsop-paris"),
    ("Horseshoe", "wsop-paris"),
    ("Aria / PokerGo", "aria"),
    ("Orleans", "orleans"),
    ("South Point", "south-point"),
    ("Golden Nugget", "golden-nugget"),
    ("MGM Grand", "mgm-grand"),
    ("Unknown Venue", None),
])
def test_slug_for_venue_display(display, expected):
    venues = load_venues(VENUES_YML)
    assert slug_for_venue_display(display, venues) == expected
