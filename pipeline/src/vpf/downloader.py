import hashlib
import json
from pathlib import Path

import requests

SHEET_ID = "1G3A8aIf-4JlvjZeiSyZ9yUzTG_fY20cLqIL3Oe6zHu4"
SHEET_XLSX_URL = f"https://docs.google.com/spreadsheets/d/{SHEET_ID}/export?format=xlsx"

# Fields whose values vary every run regardless of source data. Strip before hashing.
_VOLATILE_TOP_KEYS = {"generated_at", "source_sheet_updated_at"}


def download_sheet(dest: Path, timeout: int = 60) -> None:
    """Download the XLSX export of the sheet to `dest`."""
    resp = requests.get(SHEET_XLSX_URL, timeout=timeout, allow_redirects=True)
    resp.raise_for_status()
    dest.write_bytes(resp.content)


def content_hash(file: Path) -> str:
    return hashlib.sha256(file.read_bytes()).hexdigest()


def has_content_changed(file: Path, state_file: Path) -> bool:
    """Compare the file's hash to the value stored in state_file.

    On change (or first run), updates state_file and returns True.
    """
    new = content_hash(file)
    old = state_file.read_text().strip() if state_file.exists() else None
    if new == old:
        return False
    state_file.write_text(new)
    return True


def data_content_hash(out_dir: Path) -> str:
    """Hash the canonical pipeline outputs ignoring fields that vary every run.

    Compares tournaments.json + venues.json content with `generated_at` and
    `source_sheet_updated_at` stripped, so the hash only changes when the
    upstream tournament data actually changes — not when Google Sheets
    re-stamps the XLSX export metadata or when we mint a new ISO timestamp.
    """
    h = hashlib.sha256()
    for filename in ("tournaments.json", "venues.json"):
        path = out_dir / filename
        if not path.exists():
            continue
        doc = json.loads(path.read_text())
        if isinstance(doc, dict):
            for key in _VOLATILE_TOP_KEYS:
                doc.pop(key, None)
        # sort_keys + tight separators give a canonical byte representation.
        canonical = json.dumps(doc, sort_keys=True, separators=(",", ":")).encode()
        h.update(filename.encode())
        h.update(b"\0")
        h.update(canonical)
        h.update(b"\0")
    return h.hexdigest()


def has_data_changed(out_dir: Path, state_file: Path) -> bool:
    """Compare the canonical data hash to the value stored in state_file.

    On change (or first run), updates state_file and returns True.
    """
    new = data_content_hash(out_dir)
    old = state_file.read_text().strip() if state_file.exists() else None
    if new == old:
        return False
    state_file.write_text(new)
    return True
