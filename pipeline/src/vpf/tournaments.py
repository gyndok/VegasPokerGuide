from dataclasses import dataclass, field
from datetime import date as _date, datetime, time as _time
from typing import Optional
import re

from openpyxl.worksheet.worksheet import Worksheet

from vpf.game_category import classify_game, GameCategory
from vpf.re_entry import ReEntry, parse_re_entry
from vpf.time_utils import combine_pt


@dataclass(frozen=True)
class Tournament:
    venue_display: str
    date_pt: _date
    start_at_pt: Optional[datetime]
    late_reg_close_at_pt: Optional[datetime]
    game: str
    game_category: GameCategory
    event_name: str
    buy_in_usd: Optional[int]
    guarantee_usd: Optional[int]
    re_entry: ReEntry
    is_day2: bool
    flight_group: str
    structure_pdf_url: Optional[str] = None


@dataclass(frozen=True)
class ParseWarning:
    row_number: int
    issue: str
    raw_row: tuple


_FLIGHT_SUFFIX = re.compile(r"\s+(?:[0-9]+[A-Z]|Day\s*\d+|Final\s*Table|Turbo)\s*$", re.IGNORECASE)
_DAY2_TOKENS = ("DAY 2", "DAY2", "FINAL TABLE", "FINAL DAY")


def _to_int(value) -> Optional[int]:
    if value is None or value == "":
        return None
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return None


def _flight_group(event_name: str) -> str:
    stripped = _FLIGHT_SUFFIX.sub("", event_name).strip()
    return stripped or event_name


def _is_day2(event_name: str) -> bool:
    return any(tok in event_name.upper() for tok in _DAY2_TOKENS)


def parse_list_tab(ws: Worksheet) -> tuple[list[Tournament], list[ParseWarning]]:
    """Read the List tab. Returns (tournaments, warnings).

    Expected header columns A..I: Date, Venue, Start, LR, Game, Event, Buy-in, RE, Guarantee.
    Rows with no Event are skipped silently.
    Rows with an Event but malformed required fields produce a ParseWarning AND
    still emit a Tournament with nulls so favorites survive.
    """
    tournaments: list[Tournament] = []
    warnings: list[ParseWarning] = []

    for row_idx, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
        if len(row) < 9:
            continue
        date_val, venue, start, lr, game, event, buy_in, re_raw, guarantee = row[:9]
        if not event:
            continue

        if not isinstance(date_val, datetime) and not isinstance(date_val, _date):
            warnings.append(ParseWarning(row_idx, f"missing or non-date Date: {date_val!r}", row[:9]))
            continue

        d_only: _date = date_val.date() if isinstance(date_val, datetime) else date_val

        start_time = start if isinstance(start, _time) else None
        lr_time = lr if isinstance(lr, _time) else None

        if start is not None and start_time is None:
            warnings.append(ParseWarning(row_idx, f"unparseable Start: {start!r}", row[:9]))
        if lr is not None and lr_time is None:
            warnings.append(ParseWarning(row_idx, f"unparseable LR: {lr!r}", row[:9]))

        game_str = (game or "").strip()
        event_str = str(event).strip()

        tournaments.append(Tournament(
            venue_display=str(venue or "").strip(),
            date_pt=d_only,
            start_at_pt=combine_pt(d_only, start_time),
            late_reg_close_at_pt=combine_pt(d_only, lr_time),
            game=game_str,
            game_category=classify_game(game_str),
            event_name=event_str,
            buy_in_usd=_to_int(buy_in),
            guarantee_usd=_to_int(guarantee),
            re_entry=parse_re_entry(re_raw),
            is_day2=_is_day2(event_str),
            flight_group=_flight_group(event_str),
        ))

    return tournaments, warnings
