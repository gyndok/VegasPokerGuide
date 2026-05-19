from datetime import date
from vpf.ids import tournament_id


def test_id_is_deterministic():
    a = tournament_id("venetian", date(2026, 5, 19), "NLH 1B")
    b = tournament_id("venetian", date(2026, 5, 19), "NLH 1B")
    assert a == b


def test_id_changes_with_event_name():
    a = tournament_id("venetian", date(2026, 5, 19), "NLH 1B")
    b = tournament_id("venetian", date(2026, 5, 19), "NLH 1C")
    assert a != b


def test_id_is_slug_safe():
    id = tournament_id("Wynn", date(2026, 5, 19), "NLH (2-Day) 1A")
    assert all(c.isalnum() or c in "-" for c in id)


def test_id_includes_venue_and_date():
    id = tournament_id("venetian", date(2026, 5, 19), "NLH 1B")
    assert id.startswith("venetian-2026-05-19")
