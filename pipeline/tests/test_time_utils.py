from datetime import date, time, datetime
from vpf.time_utils import combine_pt, PACIFIC


def test_summer_offset_is_minus_seven():
    dt = combine_pt(date(2026, 5, 19), time(11, 10))
    assert dt.isoformat() == "2026-05-19T11:10:00-07:00"


def test_winter_offset_is_minus_eight():
    dt = combine_pt(date(2026, 1, 15), time(11, 10))
    assert dt.isoformat() == "2026-01-15T11:10:00-08:00"


def test_dst_spring_forward_day():
    # 2026-03-08 is DST start in US. 11:10 is after the jump.
    dt = combine_pt(date(2026, 3, 8), time(11, 10))
    assert dt.utcoffset().total_seconds() == -7 * 3600


def test_dst_fall_back_day():
    # 2026-11-01 is DST end. 11:10 is after the fall-back.
    dt = combine_pt(date(2026, 11, 1), time(11, 10))
    assert dt.utcoffset().total_seconds() == -8 * 3600


def test_returns_none_for_missing_time():
    assert combine_pt(date(2026, 5, 19), None) is None


def test_returns_none_for_missing_date():
    assert combine_pt(None, time(11, 10)) is None


def test_pacific_is_los_angeles():
    assert PACIFIC.key == "America/Los_Angeles"
