# vegas-poker-feed

Parses the SpaceyFCB Vegas summer poker schedule into JSON. Republishes to GitHub Pages.

## Run locally

```bash
cd pipeline
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# fetch and build
python -c "from vpf.downloader import download_sheet; from pathlib import Path; download_sheet(Path('.work/sheet.xlsx'))"
mkdir -p .work .out
python -m vpf.main --xlsx .work/sheet.xlsx --venues venues.yml --out-dir .out

# inspect
ls .out  # tournaments.json venues.json parse_warnings.json
```

## Tests

```bash
pytest -v
```

## GitHub Pages setup (one-time, done in GitHub UI)

1. Repo Settings → Pages → Source: `data` branch, `/ (root)`.
2. The iOS app fetches from `https://<owner>.github.io/<repo>/tournaments.json`.

## Cron

`.github/workflows/update-feed.yml` runs every 90 minutes. It will only commit when the source XLSX content changes (sha256 dedupe).
