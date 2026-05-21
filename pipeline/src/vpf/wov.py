"""wizardofviz.github.io/summer_vegas_poker enrichment fetcher.

Their page embeds the entire dataset as a const EVENTS = [...] array inline in
the HTML. We fetch the page, regex out the array, parse it, and expose it as a
list of dicts. Matching to our tournaments happens in main.py.
"""
import json
import re
from typing import Any

import requests

PAGE_URL = "https://wizardofviz.github.io/summer_vegas_poker/"


def fetch_events(timeout: int = 60) -> list[dict[str, Any]]:
    """Fetch and parse the embedded EVENTS array. Returns [] on any failure."""
    try:
        resp = requests.get(PAGE_URL, timeout=timeout, headers={"User-Agent": "kennys-list-pipeline/1"})
        resp.raise_for_status()
        return _parse_events_array(resp.text)
    except Exception:
        return []


def _parse_events_array(html: str) -> list[dict[str, Any]]:
    """Extract the const EVENTS = [...] array from the HTML page and json-parse it."""
    m = re.search(r"const\s+EVENTS\s*=\s*\[", html)
    if not m:
        return []
    start = m.end() - 1  # the '[' character
    depth = 0
    for i in range(start, len(html)):
        c = html[i]
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                try:
                    return json.loads(html[start:i + 1])
                except json.JSONDecodeError:
                    return []
    return []
