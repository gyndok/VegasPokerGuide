import json
from pathlib import Path
from vpf.downloader import content_hash, has_content_changed, data_content_hash, has_data_changed


def test_content_hash_is_stable(tmp_path: Path):
    p = tmp_path / "a.bin"
    p.write_bytes(b"hello")
    assert content_hash(p) == content_hash(p)


def test_content_hash_differs_for_different_content(tmp_path: Path):
    a = tmp_path / "a.bin"; a.write_bytes(b"hello")
    b = tmp_path / "b.bin"; b.write_bytes(b"world")
    assert content_hash(a) != content_hash(b)


def test_has_content_changed_true_when_no_prior(tmp_path: Path):
    p = tmp_path / "a.bin"; p.write_bytes(b"x")
    state = tmp_path / "state.txt"
    assert has_content_changed(p, state) is True


def test_has_content_changed_false_when_matches(tmp_path: Path):
    p = tmp_path / "a.bin"; p.write_bytes(b"x")
    state = tmp_path / "state.txt"
    has_content_changed(p, state)  # writes hash
    assert has_content_changed(p, state) is False


def test_has_content_changed_true_when_diff(tmp_path: Path):
    p = tmp_path / "a.bin"; p.write_bytes(b"x")
    state = tmp_path / "state.txt"
    has_content_changed(p, state)
    p.write_bytes(b"y")
    assert has_content_changed(p, state) is True


# --- data_content_hash / has_data_changed ---


def _write(out: Path, generated_at: str, tournaments: list, venues: list) -> None:
    (out / "tournaments.json").write_text(json.dumps({
        "generated_at": generated_at,
        "source_sheet_updated_at": generated_at,
        "tournaments": tournaments,
    }))
    (out / "venues.json").write_text(json.dumps({"venues": venues}))


def test_data_content_hash_ignores_timestamps(tmp_path: Path):
    a = tmp_path / "a"; a.mkdir()
    b = tmp_path / "b"; b.mkdir()
    tournaments = [{"id": "venetian-2026-05-19-nlh-1b", "buy_in_usd": 600}]
    venues = [{"slug": "venetian"}]
    _write(a, "2026-05-19T10:00:00Z", tournaments, venues)
    _write(b, "2026-05-19T22:00:00Z", tournaments, venues)
    assert data_content_hash(a) == data_content_hash(b)


def test_data_content_hash_changes_with_actual_data(tmp_path: Path):
    a = tmp_path / "a"; a.mkdir()
    b = tmp_path / "b"; b.mkdir()
    _write(a, "T", [{"id": "x", "buy_in_usd": 600}], [{"slug": "v"}])
    _write(b, "T", [{"id": "x", "buy_in_usd": 700}], [{"slug": "v"}])
    assert data_content_hash(a) != data_content_hash(b)


def test_has_data_changed_true_then_false_when_unchanged(tmp_path: Path):
    out = tmp_path / "out"; out.mkdir()
    state = tmp_path / "state.txt"
    _write(out, "2026-05-19T10:00:00Z", [{"id": "x"}], [{"slug": "v"}])
    assert has_data_changed(out, state) is True
    # Rewrite outputs with a different timestamp but identical data.
    _write(out, "2026-05-19T22:00:00Z", [{"id": "x"}], [{"slug": "v"}])
    assert has_data_changed(out, state) is False


def test_has_data_changed_true_when_data_differs(tmp_path: Path):
    out = tmp_path / "out"; out.mkdir()
    state = tmp_path / "state.txt"
    _write(out, "T", [{"id": "x"}], [{"slug": "v"}])
    has_data_changed(out, state)
    _write(out, "T", [{"id": "y"}], [{"slug": "v"}])
    assert has_data_changed(out, state) is True
