# Vegas Poker Guide

Personal-use iOS app + JSON feed for the SpaceyFCB Vegas summer tournament schedule.

## Layout

- `docs/superpowers/specs/` — design spec
- `docs/superpowers/plans/` — implementation plans
- `pipeline/` — Python pipeline that parses the public Google Sheet into JSON
- `ios/` — SwiftUI iPhone client (iOS 17+, iPhone only)
- `.github/workflows/` — GitHub Actions cron for the pipeline

## Status

- [x] Design spec
- [x] Pipeline implementation
- [x] iOS app

## Run the app

```bash
cd ios
xcodegen generate
open VegasPokerGuide.xcodeproj
```

Set Development Team in target settings, then Cmd+R.

To use the live feed: edit `ios/Sources/App/Config.swift` and set `feedBaseURL` to your GitHub Pages root, e.g. `https://gyndok.github.io/VegasPokerGuide`. Until then the app loads from the bundled seed feed.

## Quick links

- Source sheet: https://docs.google.com/spreadsheets/d/1G3A8aIf-4JlvjZeiSyZ9yUzTG_fY20cLqIL3Oe6zHu4/
- Sheet maintainer: https://x.com/SpaceyFCB
