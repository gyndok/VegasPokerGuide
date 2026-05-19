import json
import shutil
from pathlib import Path

from vpf.main import build_feed


def test_end_to_end_builds_all_outputs(tmp_path: Path, sheet_xlsx: Path):
    work = tmp_path / "work"
    work.mkdir()
    shutil.copy(sheet_xlsx, work / "sheet.xlsx")

    venues_yml = Path(__file__).parent.parent / "venues.yml"

    out_dir = tmp_path / "data"
    out_dir.mkdir()

    build_feed(
        xlsx_path=work / "sheet.xlsx",
        venues_yml=venues_yml,
        out_dir=out_dir,
    )

    tournaments = json.loads((out_dir / "tournaments.json").read_text())
    venues = json.loads((out_dir / "venues.json").read_text())
    warnings = json.loads((out_dir / "parse_warnings.json").read_text())

    assert tournaments["tournaments"], "expected at least some tournaments"
    assert len(venues["venues"]) == 8

    # Every emitted tournament must reference a known venue slug.
    slugs = {v["slug"] for v in venues["venues"]}
    for t in tournaments["tournaments"]:
        assert t["venue"] in slugs, f"unknown slug {t['venue']}"

    # Spot check: a known event on 18 May at Venetian must appear.
    has_may18_venetian = any(
        t["venue"] == "venetian" and t["date_pt"] == "2026-05-18"
        for t in tournaments["tournaments"]
    )
    assert has_may18_venetian

    # parse_warnings.json is well-formed even if empty.
    assert "warnings" in warnings


def test_source_sheet_updated_at_is_populated(tmp_path: Path, sheet_xlsx: Path):
    work = tmp_path / "work"; work.mkdir()
    shutil.copy(sheet_xlsx, work / "sheet.xlsx")
    out_dir = tmp_path / "data"; out_dir.mkdir()
    venues_yml = Path(__file__).parent.parent / "venues.yml"
    build_feed(xlsx_path=work / "sheet.xlsx", venues_yml=venues_yml, out_dir=out_dir)
    doc = json.loads((out_dir / "tournaments.json").read_text())
    assert doc["source_sheet_updated_at"] is not None
    assert doc["source_sheet_updated_at"].startswith("20")  # year prefix
