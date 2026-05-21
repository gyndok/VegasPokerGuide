import json
from dataclasses import asdict
from datetime import datetime
from pathlib import Path
from typing import Optional
from urllib.parse import quote_plus

from vpf.ids import tournament_id
from vpf.tournaments import Tournament, ParseWarning


def _maps_url(address: str) -> str:
    return f"https://maps.apple.com/?address={quote_plus(address)}"


def _t_to_dict(t: Tournament, venue_slug: str) -> dict:
    return {
        "id": tournament_id(venue_slug, t.date_pt, t.event_name),
        "venue": venue_slug,
        "date_pt": t.date_pt.isoformat(),
        "start_at_pt": t.start_at_pt.isoformat() if t.start_at_pt else None,
        "late_reg_close_at_pt": t.late_reg_close_at_pt.isoformat() if t.late_reg_close_at_pt else None,
        "game": t.game,
        "game_category": t.game_category,
        "event_name": t.event_name,
        "buy_in_usd": t.buy_in_usd,
        "guarantee_usd": t.guarantee_usd,
        "re_entry": asdict(t.re_entry),
        "is_day2": t.is_day2,
        "flight_group": t.flight_group,
        "structure_pdf_url": t.structure_pdf_url,
        "starting_stack": t.starting_stack,
        "level_minutes": t.level_minutes,
        "handed": t.handed,
        "rake_usd": t.rake_usd,
        "rake_pct": t.rake_pct,
        "notes": None,
    }


def write_tournaments_json(
    path: Path,
    tournaments: list[Tournament],
    venue_slug_lookup: dict[str, str],
    generated_at: datetime,
    source_sheet_updated_at: Optional[datetime],
) -> None:
    docs = []
    for t in tournaments:
        slug = venue_slug_lookup.get(t.venue_display)
        if not slug:
            continue  # unmatched venues are reported via warnings, not emitted here
        docs.append(_t_to_dict(t, slug))
    payload = {
        "generated_at": generated_at.isoformat(timespec="seconds") + ("Z" if generated_at.tzinfo is None else ""),
        "source_sheet_updated_at": (
            source_sheet_updated_at.isoformat(timespec="seconds") + ("Z" if source_sheet_updated_at and source_sheet_updated_at.tzinfo is None else "")
            if source_sheet_updated_at else None
        ),
        "tournaments": docs,
    }
    path.write_text(json.dumps(payload, indent=2))


def write_venues_json(path: Path, venues: list[dict], discovered_urls: list[str]) -> None:
    out = []
    for v in venues:
        out.append({
            "slug": v["slug"],
            "display_name": v["display_name"],
            "series_name": v.get("series_name", ""),
            "series_dates": v.get("series_dates", ""),
            "address": v.get("address", ""),
            "maps_url": _maps_url(v.get("address", "")),
            "website": v.get("website", ""),
            "structure_pdf_url": v.get("structure_pdf_url", ""),
            "color_hex": v.get("color_hex", "#888888"),
        })
    path.write_text(json.dumps({"venues": out, "discovered_urls": discovered_urls}, indent=2))


def _coerce_raw(value: object) -> object:
    """Convert non-JSON-serializable cell values (datetime, time, date) to strings."""
    if isinstance(value, (datetime,)):
        return value.isoformat()
    # time and date are not datetime subclasses, import them lazily via check
    from datetime import time as _time, date as _date
    if isinstance(value, (_time, _date)):
        return value.isoformat()
    return value


def write_warnings_json(path: Path, warnings: list[ParseWarning], generated_at: datetime) -> None:
    payload = {
        "generated_at": generated_at.isoformat(timespec="seconds") + ("Z" if generated_at.tzinfo is None else ""),
        "warnings": [
            {"row": w.row_number, "issue": w.issue, "raw_row": [_coerce_raw(v) for v in w.raw_row]}
            for w in warnings
        ],
    }
    path.write_text(json.dumps(payload, indent=2))
