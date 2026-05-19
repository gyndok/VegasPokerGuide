import pytest
from vpf.re_entry import ReEntry, parse_re_entry


@pytest.mark.parametrize("raw,expected", [
    ("UL",      ReEntry(type="unlimited",    count=None, raw="UL")),
    ("0",       ReEntry(type="single_entry", count=None, raw="0")),
    ("1",       ReEntry(type="limited",      count=1,    raw="1")),
    ("2",       ReEntry(type="limited",      count=2,    raw="2")),
    ("2x",      ReEntry(type="limited",      count=2,    raw="2x")),
    ("1/fl",    ReEntry(type="per_flight",   count=1,    raw="1/fl")),
    ("2/fl",    ReEntry(type="per_flight",   count=2,    raw="2/fl")),
    ("1e/fl",   ReEntry(type="per_flight",   count=1,    raw="1e/fl")),
    ("",        ReEntry(type="unknown",      count=None, raw="")),
    (None,      ReEntry(type="unknown",      count=None, raw="")),
    ("weird?",  ReEntry(type="unknown",      count=None, raw="weird?")),
    ("  UL  ",  ReEntry(type="unlimited",    count=None, raw="UL")),
])
def test_parse_re_entry(raw, expected):
    assert parse_re_entry(raw) == expected
