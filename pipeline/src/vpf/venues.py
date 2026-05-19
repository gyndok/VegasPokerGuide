from openpyxl.worksheet.worksheet import Worksheet


def extract_schedule_hyperlinks(ws: Worksheet) -> list[str]:
    """Walk every cell of the Schedule tab and collect external hyperlink targets."""
    urls: list[str] = []
    seen: set[str] = set()
    for row in ws.iter_rows():
        for cell in row:
            link = cell.hyperlink
            if link and link.target and link.target.startswith("http"):
                if link.target not in seen:
                    seen.add(link.target)
                    urls.append(link.target)
    return urls
