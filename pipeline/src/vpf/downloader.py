import hashlib
from pathlib import Path

import requests

SHEET_ID = "1G3A8aIf-4JlvjZeiSyZ9yUzTG_fY20cLqIL3Oe6zHu4"
SHEET_XLSX_URL = f"https://docs.google.com/spreadsheets/d/{SHEET_ID}/export?format=xlsx"


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
