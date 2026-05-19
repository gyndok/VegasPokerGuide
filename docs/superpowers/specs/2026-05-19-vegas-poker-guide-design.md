# Vegas Poker Guide — Design

**Status:** Approved scope, ready for implementation planning
**Date:** 2026-05-19
**Owner:** gyndok (personal-use app, single user)

## Overview

A SwiftUI iPhone app that surfaces the live Las Vegas summer poker tournament schedule maintained publicly by SpaceyFCB at:

`https://docs.google.com/spreadsheets/d/1G3A8aIf-4JlvjZeiSyZ9yUzTG_fY20cLqIL3Oe6zHu4/`

The app updates itself when the sheet owner edits the source. It is a personal-use planning tool — no App Store distribution, no auth, no multi-user concerns.

### Problem

The sheet is great information but inconvenient to consume on a phone in a casino: it's a wide grid (8 venues across, dates down), the time math (Pacific time, late-reg countdowns) is manual, and there's no way to filter, favorite, or track what you actually played.

### Goal

A thin native iOS client that turns the sheet into a fast, filterable, offline-capable tournament browser with a personal "My Schedule" + played log on top.

## Non-goals

- App Store distribution. Personal Apple Developer signing only.
- Multi-user / auth / sync across multiple users.
- Stack-size / blind structure detail (gap in source data — defer to a tap-through PDF link).
- Cash games (not in the sheet).
- Results scraping or leaderboards.
- Influencing the sheet owner's format. The parser must be defensive.

## Architecture

```
Google Sheet (SpaceyFCB)
        │  cron every 90 min
        ▼
GitHub Actions workflow  ─── fetches XLSX, parses List tab + extracts hyperlinks from Schedule tab
        │                    writes tournaments.json, venues.json, parse_warnings.json
        ▼
GitHub Pages              ── /tournaments.json (~150KB), /venues.json (~5KB), versioned with ETag
        │
        ▼
iOS app                   ── fetches on launch + pull-to-refresh, caches locally,
                             all filter/search/countdown logic client-side
```

### Two repos

- **`vegas-poker-feed`** — Python pipeline + curated `venues.yml` + GitHub Actions workflow. Publishes JSON to GitHub Pages from a `data` branch.
- **`vegas-poker-ios`** — SwiftUI app, iOS 17+, iPhone only, single target.

### Why this split

- Parser breakages (the sheet owner's format changes) are fixed in the pipeline repo and re-run via workflow_dispatch — no Xcode rebuild needed.
- The app stays a thin client that renders well-structured data.
- Personal use means zero infrastructure cost (GitHub Actions + Pages are free for public repos at this scale).

## Refresh strategy

- GitHub Actions cron every 90 minutes.
- iOS app re-fetches on launch and on pull-to-refresh, using `If-None-Match` (ETag).
- On `304 Not Modified`, no JSON parsing; UI shows the cached timestamp.
- No APNs push. The freshness floor (~90 min) is acceptable for tournament schedules.
- The pipeline only commits when content actually changes (sheet content hash differs from last run).

## Data model

### `tournaments.json`

```json
{
  "generated_at": "2026-05-19T14:32:00Z",
  "source_sheet_updated_at": "2026-05-19T08:55:00Z",
  "tournaments": [
    {
      "id": "venetian-2026-05-19-nlh-1b",
      "venue": "venetian",
      "date_pt": "2026-05-19",
      "start_at_pt": "2026-05-19T11:10:00-07:00",
      "late_reg_close_at_pt": "2026-05-19T17:55:00-07:00",
      "game": "NLH",
      "game_category": "nlh",
      "event_name": "NLH 1B",
      "buy_in_usd": 600,
      "guarantee_usd": 150000,
      "re_entry": {
        "type": "unlimited",
        "count": null,
        "raw": "UL"
      },
      "is_day2": false,
      "flight_group": "NLH",
      "notes": null
    }
  ]
}
```

#### Field notes

- **`id`** — deterministic hash of `venue + date + event_name`. Stable across pipeline runs so favorites/notifications survive parser changes.
- **`start_at_pt`, `late_reg_close_at_pt`** — ISO 8601 with the correct Pacific offset for that date (DST-aware via `zoneinfo`).
- **`game_category`** — enum: `nlh | plo | mixed | stud | draw | other`. Used for filter chips. Mapped from `game` string with a regex table; unrecognized → `other`.
- **`re_entry.type`** — enum: `unlimited | limited | per_flight | single_entry | unknown`. `raw` always preserved so UI can fall back to source text.
  - Parse table: `UL` → unlimited; `Nx` or `N` → limited(count=N); `N/fl` → per_flight(count=N); `Ne/fl` → per_flight(count=1, single-entry-per-flight); `0` → single_entry. Anything else → unknown.
- **`is_day2`** — true if event name contains "Day 2" or "Final Table". UI hides these from default filters; they're context, not starting events.
- **`flight_group`** — strips flight suffix so "NLH 1A", "NLH 1B", "NLH 1C" cluster as a single event in views that want them collapsed.
- **`guarantee_usd`** — null if blank in sheet.

### `venues.json`

```json
{
  "venues": [
    {
      "slug": "venetian",
      "display_name": "Venetian",
      "series_name": "Venetian DeepStack",
      "series_dates": "2026-05-18 to 2026-08-02",
      "address": "3355 S Las Vegas Blvd, Las Vegas, NV 89109",
      "maps_url": "https://maps.apple.com/?address=...",
      "website": "https://www.venetianlasvegas.com/...",
      "structure_pdf_url": "https://www.venetianlasvegas.com/.../dscps_2026-structure_21.pdf",
      "color_hex": "#8B0000"
    }
  ]
}
```

Curated by hand in `venues.yml` (8 venues for the 2026 series). Pipeline merges with sheet-discovered PDF URLs; curated values win.

### `parse_warnings.json`

```json
{
  "generated_at": "...",
  "warnings": [
    { "row": 412, "venue": "wynn", "issue": "Unrecognized re-entry value: '2/fl/ME'", "raw_row": { ... } }
  ]
}
```

Surfaced in app under Settings → "Data warnings" so format-change drift is visible.

## Pipeline behavior

1. Cron triggers (or `workflow_dispatch`). Runs every 90 min.
2. `curl` the sheet's XLSX export URL.
3. SHA-256 the raw bytes; compare to last-run hash stored in repo. If unchanged, exit clean.
4. Parse `List` tab as primary source.
5. Parse `Schedule` tab only to extract `Target=` hyperlinks per venue column, building a venue→PDF map.
6. Apply `venues.yml` overrides (curated values take precedence).
7. Normalize re-entry, compute IDs, build PT-zoned datetimes.
8. Write `tournaments.json`, `venues.json`, `parse_warnings.json` to the `data` branch.
9. GitHub Pages auto-publishes from `data` branch.

### Parser tests

- Unit tests over a fixture XLSX checked into the repo: re-entry parsing matrix, DST boundary dates, day-2 detection, flight-group extraction.
- CI runs tests on every push.

## iOS app structure

SwiftUI, iOS 17+, iPhone only. Three-tab `TabView`.

### Tab 1 — Schedule (default)

- Sticky header: search bar + Filters pill (badge with active filter count).
- List grouped by date, sticky day headers (`Tue 19 May · Today`).
- Row card: venue color bar · time · event name · buy-in · LR countdown badge.
- Toolbar: "Today" jump button, refresh indicator, Settings gear.
- Tap row → Event Detail sheet.

### Filters sheet (modal)

- Date range: presets (Today / Tomorrow / This Weekend / Next 7 Days / All) + custom range pickers.
- Venues: chip multi-select (all 8, color-coded).
- Buy-in range: dual-thumb slider, $0 – $10,000+.
- Guarantee range: dual-thumb slider, $0 – $2M+, "Any" toggle.
- Game type: chip multi-select (NLH, PLO, Mixed, Stud, Draw, Other).
- Re-entry policy: chips (Unlimited, Limited, Per-flight, Single).
- Late-reg status: All / Open now / Closing within 2hr / Closed.
- Reset + Apply footer.

### Event Detail (modal, large)

- Venue color bar, star toggle, share/copy menu.
- Event name, game category chip.
- Two-column grid: Buy-in / Guarantee / Starts (PT, with user TZ sublabel) / Late reg closes.
- Live LR countdown card with color states:
  - **green** > 2hr, **amber** < 2hr, **red** < 30min, **grey** closed.
  - Updates every second when visible, every minute when not.
- Re-entry policy (parsed phrase + raw text).
- Action row: Open Structure Sheet (PDF), Directions to venue, Add to Calendar, Notify before LR.
- Free-text Notes field, persisted locally.
- Played toggle (Yes/No) + Cashed amount field.

### Tab 2 — My Schedule

- Same date-grouped list but only starred events.
- Top summary card: count + total buy-in for the date range shown.
- Conflict warning banner when two starred events overlap in start→LR-close window.
- Empty state directs to Schedule tab.

### Tab 3 — Played

- Chronological log of events marked Played.
- Top: running totals (entries / $ in / $ cashed / net) over a date range.
- Per-row: date, venue, event, buy-in, cashed, net.

### Settings

- Last-updated timestamp + manual refresh.
- Time-zone display preference: Pacific only / Pacific + my TZ (default).
- Notification lead-time slider (15 / 30 / 60 min).
- Format tag style: Icons / Text / Off.
- Data warnings (from `parse_warnings.json`).
- About + attribution to SpaceyFCB (link to x.com/SpaceyFCB and ko-fi).

### Visual / interaction

- Native iOS 17 look (system materials, Liquid Glass where appropriate).
- Venue accent colors: one per venue, used on row left edge and chips.
- Game-category chips: NLH blue, PLO orange, MIX purple, STUD green, DRAW teal, OTHER grey.
- All times shown in PT by default with optional user-TZ sublabel.

## Local storage

JSON files in the app's documents directory. No SwiftData / Core Data needed — data is small and single-user.

- `tournaments_cache.json` — last fetched feed (offline source).
- `favorites.json` — set of tournament IDs.
- `notes.json` — `{id: string}` map.
- `played.json` — list of `{id, date, buy_in, cashed}` records.
- `notifications.json` — `{id, fireDate, leadMinutes}` map for cleanup on unstar / past-LR.

## Tech stack

- **SwiftUI** with `Observable` macros (iOS 17+).
- **URLSession** with `URLCache` + manual ETag for the JSON feed.
- **UserNotifications** for LR reminders.
- **EventKit** for Calendar add.
- **MapKit** URL scheme for directions (`maps.apple.com/?address=...`).
- **Foundation** `Date`, `Calendar`, `TimeZone(identifier: "America/Los_Angeles")` for PT-aware logic.
- **Tests:** XCTest snapshot tests on key views; unit tests on filter logic, countdown state machine, ID stability.

## Pipeline tech stack

- **Python 3.12** with `openpyxl` (XLSX parsing, including hyperlink extraction from `_rels/`).
- **GitHub Actions** for cron + publish.
- **`zoneinfo`** for DST-correct PT datetimes.
- **`pytest`** for parser tests.
- **GitHub Pages** serving from `data` branch.

## Notifications & state lifecycle

- Star + enable LR notification → schedule local notification at `late_reg_close_at_pt - leadMinutes`.
- Unstar → cancel scheduled notification for that ID.
- LR has passed → no-op (don't schedule), and on next app launch prune any stale pending notifications.
- App provides a single bulk "rebuild all notifications" routine called after each feed refresh, in case event times shifted.

## Time-zone handling

- All times in the JSON are stored as ISO 8601 with the literal Pacific offset (`-07:00` in summer DST, `-08:00` otherwise).
- App parses to `Date` (an absolute instant).
- Display uses two `DateFormatter`s — one fixed to `America/Los_Angeles`, one to the user's current zone.
- Countdown is `Date().timeIntervalSince(lateRegClose)` — TZ-independent because both are absolute instants.

## Open questions / future work

- **Stack size + level length** — deferred. Possible v2: OCR or hand-parse venue PDFs into the JSON feed.
- **Lock Screen Live Activity** — countdown on the lock screen for the next LR deadline. Real engineering, deferred.
- **Home Screen widget** — next starred event with countdown. Possible v2.
- **"What's running right now"** view — events currently in their LR window across all venues. Possible v2.
- **Re-entry math calculator** — replicating the sheet's Buy-ins tab logic. Possible v2.
- **Multi-series support** — when SpaceyFCB drops a new schedule (fall, WSOP main, etc.), pipeline currently assumes one sheet. Generalize when needed.

## Risks

- **Source format drift** — SpaceyFCB can change column order, add venues, change re-entry shorthand. Mitigations: parser is defensive, `parse_warnings.json` surfaces unparseable rows in the app, fixes ship without app rebuild.
- **Hyperlink discovery** — relies on hyperlinks living in the XLSX export. If the owner switches to plaintext URLs in cells, fall back to plain-URL regex on cell values.
- **Cron lag** — 90-min freshness floor. Acceptable; user can pull-to-refresh.
- **Time zone bugs** — DST and traveling user are classic failure modes. Snapshot tests on PT boundary dates and a non-PT device locale.

## Attribution

The sheet is the work of SpaceyFCB (x.com/SpaceyFCB, ko-fi.com/spaceyfcb). The Settings → About screen credits this clearly and links both URLs. Since the app is personal-use only and never distributed, no formal permission is required — but credit is right.
