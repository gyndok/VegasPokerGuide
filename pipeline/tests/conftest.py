from pathlib import Path
import pytest

FIXTURE_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def sheet_xlsx() -> Path:
    return FIXTURE_DIR / "sheet_2026-05-19.xlsx"
