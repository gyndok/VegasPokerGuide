from vpf.wov import _parse_events_array


def test_parse_extracts_events_from_inline_array():
    html = """
    <html><body><script>
    const EVENTS = [
        {"Location": "Venetian", "DATE": "2026-05-19", "Event": "NLH", "Buy-in": 600},
        {"Location": "Wynn", "DATE": "2026-05-19", "Event": "PLO", "Buy-in": 1100}
    ];
    </script></body></html>
    """
    events = _parse_events_array(html)
    assert len(events) == 2
    assert events[0]["Location"] == "Venetian"
    assert events[1]["Buy-in"] == 1100


def test_parse_returns_empty_on_missing_array():
    assert _parse_events_array("<html>nothing here</html>") == []


def test_parse_returns_empty_on_malformed_json():
    assert _parse_events_array("const EVENTS = [{malformed}]") == []
