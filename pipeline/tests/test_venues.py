from openpyxl import load_workbook
from vpf.venues import extract_schedule_hyperlinks


def test_extracts_pdf_urls(sheet_xlsx):
    wb = load_workbook(sheet_xlsx)  # NOT data_only — preserve hyperlinks
    urls = extract_schedule_hyperlinks(wb["Schedule 2026"])
    # urls is a set of absolute URLs
    assert any("venetianlasvegas.com" in u for u in urls)
    assert any("wynnresorts.com" in u for u in urls)
    assert any("wsop.gg-global-cdn.com" in u for u in urls)
    assert any("southpointcasino.com" in u for u in urls)


def test_urls_are_unique(sheet_xlsx):
    wb = load_workbook(sheet_xlsx)
    urls = extract_schedule_hyperlinks(wb["Schedule 2026"])
    assert len(urls) == len(set(urls))
