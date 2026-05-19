from pathlib import Path
from vpf.downloader import content_hash, has_content_changed


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
