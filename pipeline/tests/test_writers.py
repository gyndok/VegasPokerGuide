import json
from datetime import date, datetime
from pathlib import Path

from vpf.ids import tournament_id
from vpf.re_entry import ReEntry
from vpf.time_utils import combine_pt
from vpf.tournaments import Tournament, ParseWarning
from vpf.writers import write_tournaments_json, write_venues_json, write_warnings_json


def _sample_tournament() -> Tournament:
    return Tournament(
        venue_display="Venetian",
        date_pt=date(2026, 5, 19),
        start_at_pt=combine_pt(date(2026, 5, 19), datetime(2026, 5, 19, 11, 10).time()),
        late_reg_close_at_pt=combine_pt(date(2026, 5, 19), datetime(2026, 5, 19, 17, 55).time()),
        game="NLH",
        game_category="nlh",
        event_name="NLH 1B",
        buy_in_usd=600,
        guarantee_usd=150000,
        re_entry=ReEntry("unlimited", None, "UL"),
        is_day2=False,
        flight_group="NLH",
    )


def test_tournaments_json_shape(tmp_path: Path):
    out = tmp_path / "tournaments.json"
    write_tournaments_json(
        out,
        tournaments=[_sample_tournament()],
        venue_slug_lookup={"Venetian": "venetian"},
        generated_at=datetime(2026, 5, 19, 14, 32, 0),
        source_sheet_updated_at=datetime(2026, 5, 19, 8, 55, 0),
    )
    doc = json.loads(out.read_text())
    assert doc["generated_at"].startswith("2026-05-19T14:32")
    assert len(doc["tournaments"]) == 1
    t = doc["tournaments"][0]
    assert t["id"] == tournament_id("venetian", date(2026, 5, 19), "NLH 1B")
    assert t["venue"] == "venetian"
    assert t["date_pt"] == "2026-05-19"
    assert t["start_at_pt"] == "2026-05-19T11:10:00-07:00"
    assert t["late_reg_close_at_pt"] == "2026-05-19T17:55:00-07:00"
    assert t["game"] == "NLH"
    assert t["game_category"] == "nlh"
    assert t["event_name"] == "NLH 1B"
    assert t["buy_in_usd"] == 600
    assert t["guarantee_usd"] == 150000
    assert t["re_entry"] == {"type": "unlimited", "count": None, "raw": "UL"}
    assert t["is_day2"] is False
    assert t["flight_group"] == "NLH"
    assert t["structure_pdf_url"] is None


def test_venues_json_shape(tmp_path: Path):
    venues = [
        {"slug": "venetian", "display_name": "Venetian", "color_hex": "#8B0000",
         "address": "addr", "website": "https://x", "structure_pdf_url": "https://y",
         "series_name": "Series", "series_dates": "...", "match_terms": ["Venetian"]},
    ]
    out = tmp_path / "venues.json"
    write_venues_json(out, venues=venues, discovered_urls=["https://x.example/extra.pdf"])
    doc = json.loads(out.read_text())
    assert doc["venues"][0]["slug"] == "venetian"
    assert doc["venues"][0]["maps_url"].startswith("https://maps.apple.com/")
    # discovered_urls should be present for debugging
    assert "discovered_urls" in doc


def test_warnings_json_shape(tmp_path: Path):
    out = tmp_path / "parse_warnings.json"
    warnings = [ParseWarning(row_number=42, issue="bad time", raw_row=(1, 2, 3))]
    write_warnings_json(out, warnings=warnings, generated_at=datetime(2026, 5, 19, 14, 32, 0))
    doc = json.loads(out.read_text())
    assert doc["warnings"][0]["row"] == 42
    assert doc["warnings"][0]["issue"] == "bad time"
