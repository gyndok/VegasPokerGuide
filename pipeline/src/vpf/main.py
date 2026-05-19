import argparse
from datetime import datetime, timezone
from pathlib import Path

from openpyxl import load_workbook

from vpf.tournaments import parse_list_tab, ParseWarning
from vpf.venues import extract_schedule_hyperlinks, load_venues, slug_for_venue_display, merge_pdf_urls
from vpf.writers import write_tournaments_json, write_venues_json, write_warnings_json


def build_feed(xlsx_path: Path, venues_yml: Path, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)

    wb_links = load_workbook(xlsx_path)             # keep hyperlinks
    wb_data = load_workbook(xlsx_path, data_only=True)

    tournaments, warnings = parse_list_tab(wb_data["List"])
    discovered_urls = extract_schedule_hyperlinks(wb_links["Schedule 2026"])
    venues = load_venues(venues_yml)
    venues = merge_pdf_urls(venues, discovered_urls)

    venue_slug_lookup: dict[str, str] = {}
    for t in tournaments:
        if t.venue_display in venue_slug_lookup:
            continue
        slug = slug_for_venue_display(t.venue_display, venues)
        if slug:
            venue_slug_lookup[t.venue_display] = slug
        else:
            warnings.append(ParseWarning(
                row_number=0,
                issue=f"unknown venue: {t.venue_display!r}",
                raw_row=(t.venue_display,),
            ))

    now = datetime.now(timezone.utc).replace(tzinfo=None)  # plain UTC for ISO 'Z'

    source_mtime = datetime.fromtimestamp(xlsx_path.stat().st_mtime, tz=timezone.utc).replace(tzinfo=None)
    write_tournaments_json(
        out_dir / "tournaments.json",
        tournaments=tournaments,
        venue_slug_lookup=venue_slug_lookup,
        generated_at=now,
        source_sheet_updated_at=source_mtime,
    )
    write_venues_json(out_dir / "venues.json", venues=venues, discovered_urls=discovered_urls)
    write_warnings_json(out_dir / "parse_warnings.json", warnings=warnings, generated_at=now)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Build vegas-poker JSON feed from XLSX")
    parser.add_argument("--xlsx", type=Path, required=True)
    parser.add_argument("--venues", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args(argv)
    build_feed(args.xlsx, args.venues, args.out_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
