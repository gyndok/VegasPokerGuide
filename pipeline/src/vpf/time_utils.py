from datetime import date as _date, time as _time, datetime
from typing import Optional
from zoneinfo import ZoneInfo

PACIFIC = ZoneInfo("America/Los_Angeles")


def combine_pt(d: Optional[_date], t: Optional[_time]) -> Optional[datetime]:
    """Combine a Pacific calendar date and clock time into a tz-aware datetime."""
    if d is None or t is None:
        return None
    naive = datetime.combine(d, t)
    return naive.replace(tzinfo=PACIFIC)
