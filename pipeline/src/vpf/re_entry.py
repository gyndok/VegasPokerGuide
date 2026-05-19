from dataclasses import dataclass
from typing import Literal, Optional
import re

ReEntryType = Literal["unlimited", "limited", "per_flight", "single_entry", "unknown"]


@dataclass(frozen=True)
class ReEntry:
    type: ReEntryType
    count: Optional[int]
    raw: str


_PER_FLIGHT = re.compile(r"^(\d+)\s*e?\s*/\s*fl$", re.IGNORECASE)
_LIMITED = re.compile(r"^(\d+)\s*x?$", re.IGNORECASE)


def parse_re_entry(raw: object) -> ReEntry:
    text = "" if raw is None else str(raw).strip()
    if not text:
        return ReEntry("unknown", None, "")
    upper = text.upper()
    if upper == "UL":
        return ReEntry("unlimited", None, text)
    if text == "0":
        return ReEntry("single_entry", None, text)
    if m := _PER_FLIGHT.match(text):
        return ReEntry("per_flight", int(m.group(1)), text)
    if m := _LIMITED.match(text):
        return ReEntry("limited", int(m.group(1)), text)
    return ReEntry("unknown", None, text)
