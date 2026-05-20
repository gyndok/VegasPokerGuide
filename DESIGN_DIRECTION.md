# Design Direction — "Felt & Foil"

**Status:** Phase 1 deliverable. Awaits approval before Phase 2 (Design Tokens).
**Brief:** `vegas_poker_app_prompt.md` (delivered separately).
**Owner:** gyndok. Personal-use iOS app, single device, no App Store distribution.

---

## Locked decisions (from intake)

1. **Fonts** — Free SIL OFL: **Fraunces** (display) + **Inter** (body) + **JetBrains Mono** (numerics).
2. **Felt texture** — Pre-rendered PNG asset on big surfaces only. Flat color in row interiors.
3. **Iconography** — Tab bar: restyled SF Symbols with foil-gradient mask + display-font labels. Empty states: bespoke SwiftUI `Path` shapes.
4. **Dark mode anchor** — Rail-black dominant (OLED true-black surfaces). Felt-green appears as accent on key cards.
5. **Control replacement strategy** — Graceful degradation: aggressive restyling of stock SwiftUI controls is accepted as "replacement" when structural replacement would forfeit iOS free behaviors (TabView, .searchable, Picker, Toggle).

---

## 1 · Surface inventory

For each surface: what stock Apple chrome bleeds through today, and the one or two highest-impact moves that shift it away from default.

### RootTabs

**Stock chrome bleeding through:**
- Default `TabView` bottom bar with system blur material.
- SF Symbols (`list.bullet`, `star.fill`, `checkmark.seal`) tinted with `Color.accentColor`.
- System tab label font and color.
- iOS 26 floating tab bar treatment applied automatically.

**Highest-impact moves:**
- Custom bottom-bar background: rail-black opaque fill with a single foil hairline on the top edge. No blur.
- Foil-gradient mask on the selected tab's icon; dim-foil for unselected. Display-font labels (Fraunces tabular, 11pt all-caps tracked).

### ScheduleTab

**Stock chrome:**
- `.navigationTitle("Schedule")` rendered in system display font (large title).
- `.searchable` system search field with default placeholder treatment.
- `Image(systemName: "gearshape")` and `Label("Filters (N)", systemImage: "line.3.horizontal.decrease.circle")` in system styling.
- Default `List(.plain)` background; system row separators and insets.
- System pull-to-refresh spinner.

**Highest-impact moves:**
- `AppSheetHeader`-style title: Fraunces 28pt, foil hairline beneath spanning the safe-area width.
- `AppSearchField` replacing the system search bar — foil-edged input, JetBrains-Mono placeholder.
- Custom pull-to-refresh: a single chip flipping on its Y axis (Phase 5).

### DayHeader

**Stock chrome:**
- `.headline` font, `.subheadline` for the "Today"/"Tomorrow" suffix, `.secondary` color.
- System date-grouping section header background.

**Highest-impact moves:**
- Fraunces 16pt for the date string; Inter 11pt all-caps tracked for the relative label ("TODAY", "TOMORROW").
- Full-width foil hairline beneath each header.

### EventRow

**Stock chrome:**
- `HStack` with `.body.weight(.medium)` event name and `.caption.monospacedDigit()` numbers.
- `Label(time, systemImage: "clock")` with `.secondary` color.
- `Image(systemName: "star.fill")` in `.yellow` for starred rows.
- System List row separator.

**Highest-impact moves:**
- **Tabular-numeric discipline** — all numbers (time, buy-in) in JetBrains Mono with `tnum` feature forced.
- **`BuyInBadge`** — chip-tier color dot beside the dollar figure (white/red/green/black/purple/gold/platinum by denomination). This is the strongest "this is a poker app" signal in the entire UI.
- `StarToggle` glyph: a custom chip-plaque or card-pip shape, not an SF Symbol star.
- `AppRowBackground`: flat rail-soft fill in dark mode, paper-cream in light. Foil hairline separator between rows replaces the system separator.

### CountdownBadge

**Stock chrome:**
- System color tokens: `.green`, `.orange`, `.red`, `.gray`, `.secondary`.
- `.font(.caption.monospacedDigit())` — system mono, not JetBrains Mono.

**Highest-impact moves:**
- Replace system colors with semantic state tokens (`AppColor.state.live` / `.urgent` / `.closed`). Neon accent reserved for the `<30min` urgent tier.
- Foil hairline frame around the badge in EventRow context.
- In the EventDetail big card: foil-gradient border + felt-noise interior + JetBrains Mono 32pt for the running digits.

### MyScheduleTab

**Stock chrome:**
- `SummaryCard` is a plain `HStack` with stock fonts and `Spacer()`.
- `ConflictBanner` uses `Label("...", systemImage: "exclamationmark.triangle.fill")` in `.orange`.
- `ContentUnavailableView` for the empty state — stock SF Symbol star, system gray label.

**Highest-impact moves:**
- Summary in a `SectionCard` with foil-edged frame. "N STARRED EVENTS" in Fraunces small-caps; total buy-in in JetBrains Mono 24pt.
- `ConflictBanner` is **the** place neon-urgent earns its keep — neon-coral fill, custom diamond-warning glyph, foil hairline. The only place in the app where high-contrast color screams.
- `AppEmptyState` with a custom illustration: a faded chip stack with a single star floating above. Drawn in SwiftUI `Path`.

### PlayedTab

**Stock chrome:**
- 4-stat row uses stock `.caption` labels and `.body.monospacedDigit()` values.
- Per-row `-$X` in system `.red`, `+$Y` in system `.green`.
- `ContentUnavailableView` for empty state.

**Highest-impact moves:**
- 4-stat row as a `SectionCard` with foil hairlines between stats and JetBrains Mono 22pt values, Fraunces small-caps 10pt labels. Reads like a tournament structure sheet's payout summary.
- Per-row amounts in restrained brand palette: chip-red (`#C8313E`) and felt-green (`#2E7D5B`), not system red/green. Same hue family as the chip-tier dots.
- Empty state: a folded card with a question mark, custom illustration.

### FiltersSheet

**Stock chrome:**
- SwiftUI `Form` with system insets and grouped section dividers.
- Default `Section("Title")` headers in system small-caps.
- Default `Toggle`, `TextField` (numberPad), `Picker.segmented`, `Button` controls.
- Default `NavigationStack` title and "Done" toolbar button.

**Highest-impact moves:**
- `AppSheetHeader` replaces the navigation title — display-font title, foil hairline beneath, custom "Done" button.
- Date presets become a horizontal scroll of **chip-shaped `AppButton`s** (the chip metaphor again).
- Venue and game-category toggles become **chip-pip `AppToggle`s** — round chip silhouette that fills with venue color when on.
- Late-reg picker becomes a custom segmented chip group (four chips, the selected one inset with a foil ring).
- Reset is `AppButton.destructive` — chip-red outline, no fill, prominent at the bottom.

### EventDetail

**Stock chrome:**
- `.navigationTitle("")` empty + stock back chevron.
- Default `ScrollView` background.
- Stock fonts on the title and stats grid.
- System `Image(systemName: "star.fill")` in `.yellow`.
- `Link` and `Button(.bordered)` for the action row.
- `.thinMaterial` background on the countdown card — generic iOS material.
- Default `TextEditor` for notes; default `Toggle` for Played.

**Highest-impact moves:**
- Event name in Fraunces 28pt, semibold. Venue color bar on the leading edge of the whole sheet.
- Two-column stats grid as two `SectionCard`s side-by-side, foil-hairline framing each cell, JetBrains Mono values.
- **Live countdown card is the showpiece** — foil-gradient border (animated), felt-noise interior, JetBrains Mono 36pt digits, neon accent that intensifies as the tier escalates.
- Action row buttons as `AppButton.primary` — chip-shaped silhouette, display-font label.
- Notes section styled like a tournament structure sheet's handwritten-notes line: Inter 15pt on cream-toned panel with a foil left edge.
- Played section as a small `SectionCard` matching the Played tab's stat language.

### SettingsSheet

**Stock chrome:**
- SwiftUI `Form` again, with all its system insets.
- `LabeledContent` stock layout.
- System `.green` / `.orange` / `.red` on data-warning labels.
- Default `Link` for source URLs.

**Highest-impact moves:**
- Replace `Form` with stacked `SectionCard`s — same component used everywhere else.
- "Refresh now" as `AppButton.primary` (chip-shaped). Data warnings: brand-restrained green/amber, not system.
- Source links as `AppButton.secondary` (foil outline only). Attribution prose in Inter 13pt italic on cream background.

---

## 2 · Mood board (in words)

1. **Tournament structure-sheet PDFs (Venetian DeepStack, Aria PokerGo, WSOP).** Monospaced typewriter columns, hairline tables, ALL-CAPS section labels, restrained ornament. Heaviest influence on EventDetail's stats grid and the Played 4-stat row. This is the document we are essentially making interactive.

2. **High-denomination chip plaques ($5K–$25K).** Dyed-foil rectangles with centered display type, hairline frame, color-on-color tier marker. Direct model for `BuyInBadge` at high denominations and for the chip-shaped silhouette used by primary buttons and tab labels.

3. **Classic Bicycle card-back engraving (the white-back design).** Fine repeated linework, decorative-but-restrained. Inspires foil hairline density and the engraved-line treatment on the empty-state illustrations.

4. **WPT structure-sheet PDFs + EPT brand wordmarks.** Quieter than WSOP broadcast — print-design discipline, serif display + sans body + mono tables. Sets the broader visual register, especially for SettingsSheet and the About copy.

5. **Vintage Binion's Horseshoe collateral.** Black-and-foil program covers, restrained ornament. The "rail-black + foil" color anchor of dark mode is essentially this aesthetic.

6. **Aria poker-room high-stakes section signage.** Amber-warm dim lighting, brushed brass, dark wood. Anchors the dark-mode mood: dim is the default state, foil glints rather than blasts.

**Explicit non-references** (things we are *not* doing): WSOP broadcast lower-thirds (too loud and TV-aggressive), online-poker app UIs (too animation-heavy and slot-machine-adjacent), Vegas Strip casino signage (too consumer-marketing). This is a tournament app, not a casino product.

---

## 3 · Color story

All raw hex lives in `AppColor.swift` (Phase 2). Every other file consumes semantic tokens.

### Foundation surfaces

| Token | Hex | Use |
|---|---|---|
| `AppColor.rail.true` | `#0A0A0B` | Dark-mode app background (OLED true-black). |
| `AppColor.rail.soft` | `#15161A` | Dark-mode lifted card surfaces. Slight elevation cue without translucency. |
| `AppColor.felt.dark` | `#1A4D2E` | Felt-green primary accent. Used on live countdown card, conflict banner backdrop, star plaque fill. |
| `AppColor.felt.deep` | `#103018` | Felt-green shadow depth. Used as the gradient anchor under the felt PNG texture. |
| `AppColor.paper.cream` | `#F5EFE6` | Light-mode app background. Warm, paper-like. The "tournament structure sheet" surface. |
| `AppColor.paper.warm` | `#E8DFD0` | Light-mode subtle elevation. |

### Foil / brass (the "Foil" of "Felt & Foil")

| Token | Hex | Use |
|---|---|---|
| `AppColor.foil.bright` | `#D4AF37` | Hairlines on cards, dividers, frames around live elements. Foil-gradient masks. |
| `AppColor.foil.muted` | `#8A7224` | Lower-emphasis borders. Default divider in dark mode. |
| `AppColor.foil.dim` | `#5A4A17` | Subtle hairlines on inactive elements. |

### Neon accent (live/urgent ONLY)

| Token | Hex | Use |
|---|---|---|
| `AppColor.neon.live` | `#00FF94` | Running countdown card, `>2hr` tier. The only "alive" green in the app. |
| `AppColor.neon.urgent` | `#FF3B5C` | Countdown `<30min`, conflict banner fill. Used sparingly — two contexts total. |

### Chip-tier color coding (BuyInBadge)

Standard poker denomination convention, applied as the dot beside the dollar figure.

| Tier | Range | Token | Hex |
|---|---|---|---|
| White | $0 – $4 | `AppColor.chip.white` | `#F5F0E8` |
| Red | $5 – $24 | `AppColor.chip.red` | `#C8313E` |
| Green | $25 – $99 | `AppColor.chip.green` | `#2E7D5B` |
| Black | $100 – $499 | `AppColor.chip.black` | `#1A1A1B` |
| Purple | $500 – $999 | `AppColor.chip.purple` | `#6B2E8C` |
| Gold | $1,000 – $4,999 | `AppColor.chip.gold` | `#D4AF37` |
| Platinum | $5,000+ | `AppColor.chip.platinum` | `#B9C5D0` |

The dot is rendered as a small circle with a thin foil hairline. At $5K+ the platinum tier deserves the rectangular plaque treatment (foil-framed rectangle instead of dot) to signal the jump.

### Text

| Token | Dark mode | Light mode |
|---|---|---|
| `AppColor.text.primary` | `#F5EFE6` (paper cream) | `#15161A` (rail soft) |
| `AppColor.text.secondary` | `#B0A99A` | `#5A554D` |
| `AppColor.text.tertiary` | `#6E6A60` | `#8A8278` |

### Semantic state

| Token | Hex | Use |
|---|---|---|
| `AppColor.state.live` | `#00FF94` (neon.live) | Running countdown, >2hr tier. |
| `AppColor.state.urgent` | `#FF3B5C` (neon.urgent) | <30min countdown, conflict banner. |
| `AppColor.state.closed` | `#6E6A60` | Closed badge, ended sections. |
| `AppColor.state.success` | `#5BA876` | Restrained brand-green for "no warnings" indicator and +$cashed in Played. |
| `AppColor.state.warning` | `#E8A04B` | Restrained brand-amber for data warnings indicator. |

### Venue accents

Venue colors stay tied to each venue's brand identity (from `venues.yml`), but are normalized to ~70% saturation against the rail-black background to prevent any one venue from screaming. Implementation: `AppColor.venueAccent(slug:)` reads the curated hex and applies a luminance clamp.

---

## 4 · Typography pairing

All free SIL OFL fonts. Embedded in the app bundle and registered via `Info.plist` `UIAppFonts`.

### Faces

| Role | Face | Why |
|---|---|---|
| **Display** | **Fraunces** | Variable-axis serif (weight 100–900, optical-size 9–144, softness 0–100). The optical-size axis at high values (~72) gives a brassy, broadcast-headline feel ideal for the EventDetail title; at low values (~14) it stays readable for tab labels. SIL OFL. |
| **Body** | **Inter** | The most-shipped UI sans face in the industry. Excellent legibility at 12–16pt, ships a true italic, hinted for screen. SIL OFL. |
| **Mono** | **JetBrains Mono** | True tabular figures, exceptional digit shape (0/O/8 distinguished), six weights. The countdown will not reflow under any circumstance. SIL OFL. |

### Named presets (Phase 2 `AppFont.swift`)

Sizes target the Default Dynamic Type setting. All presets use `Font.custom(...)` with `relativeTo:` to scale under user preference.

| Preset | Face | Size | Weight | Notes |
|---|---|---|---|---|
| `.tabTitle` | Fraunces | 11 (→ `.caption`) | semibold | Optical 14, all-caps, +60 tracking |
| `.largeTitle` | Fraunces | 28 (→ `.title`) | semibold | Optical 36 |
| `.sheetTitle` | Fraunces | 22 (→ `.title2`) | semibold | Used in AppSheetHeader |
| `.eventName` | Fraunces | 17 (→ `.body`) | medium | Optical 18 |
| `.dayHeader` | Fraunces | 16 (→ `.headline`) | semibold | + Inter 11pt all-caps for the "TODAY" suffix |
| `.sectionLabel` | Inter | 10 (→ `.caption2`) | semibold | All-caps, +120 tracking |
| `.bodyCopy` | Inter | 15 (→ `.body`) | regular | Settings text, notes |
| `.meta` | Inter | 12 (→ `.caption`) | regular | Row metadata (time labels, secondary info) |
| `.notesBody` | Inter | 15 (→ `.body`) | regular italic | Notes section editor |
| `.buyIn` | JetBrains Mono | 14 (→ `.subheadline`) | medium | Row buy-in figure |
| `.buyInLarge` | JetBrains Mono | 22 (→ `.title2`) | semibold | EventDetail header buy-in |
| `.countdown` | JetBrains Mono | 13 (→ `.caption`) | medium | Row CountdownBadge |
| `.countdownLarge` | JetBrains Mono | 36 (→ `.largeTitle`) | semibold | EventDetail showpiece countdown |
| `.stat` | JetBrains Mono | 22 (→ `.title2`) | semibold | Played 4-stat values, SummaryCard total |
| `.timestamp` | JetBrains Mono | 12 (→ `.caption`) | regular | "Last updated", LR/start time strings |

All mono presets force `tnum` (tabular figures) via `font.featureSettings`.

Dynamic Type works because every preset is declared `relativeTo:` a system style. Custom fonts scale just like SF Pro.

---

## 5 · Texture & material strategy

Three-layer rule for surface treatment:

**Felt-noise PNG asset** — high-fidelity tiled texture (~120 KB compressed), one variant for dark mode (felt-green over rail-black), one variant for light mode (subtle paper grain over cream). Applied only on:
- `AppTabBar` background (the full bottom-bar zone).
- `AppSheetHeader` (the top ~88pt of every modal sheet).
- EventDetail's live countdown card interior.

Felt noise NEVER appears in row interiors or scrolling list backgrounds — those stay flat for performance.

**Foil/brass hairlines** — 0.5pt foil-bright lines used as:
- Card edges (`SectionCard`).
- Section dividers within cards.
- Beneath every `DayHeader`.
- Frame around `CountdownBadge`.
- Frame around high-denomination `BuyInBadge` (platinum tier).
- Top edge of `AppTabBar`.
- Beneath `AppSheetHeader`.

For animated foil treatment (live countdown card border), the line is rendered as a 1pt-wide `LinearGradient` that subtly cycles brightness over 4s — barely noticeable, but it makes the card feel "alive" without being distracting.

**Flat color** — everywhere else. Row interiors, button backgrounds, toggle fills. Performance budget for the 600+ row Schedule list demands this.

**No translucent material anywhere.** `.thinMaterial`, `.regularMaterial`, `.ultraThinMaterial` are banned. They're the single most generic-iOS-app signal in the visual layer. Replaced with opaque `AppColor.rail.soft` (dark) / `#FFFFFF` (light) fills with foil hairline framing.

---

## 6 · Motion & feedback principles

Restraint is the rule. Every motion has a job; nothing is decorative.

### List motion

- **EventRow enter (initial list load only):** opacity 0→1 + translateY 8→0, 0.18s ease-out, staggered ~30ms per row, max 8 rows visible at once. Subsequent re-renders (filter change, refresh) just snap — no stagger.
- **Filter chip selection:** scale-bounce 1.0 → 0.92 → 1.04 → 1.0 over 0.22s spring; foil hairline peaks brightness at the bounce apex. Haptic: `AppHaptics.filterApplied` (UIImpactFeedbackGenerator.light).
- **Day-section sticky behavior:** unchanged — system scroll behavior is right.

### Action motion

- **Star toggle:** chip-flip on Y axis, 0.32s ease-in-out. Plaque face rotates 180° to reveal the foil-engraved star. Haptic: `AppHaptics.starToggled` (UIImpactFeedbackGenerator.medium).
- **Pull-to-refresh:** custom indicator — a single chip flipping continuously on its Y axis until refresh resolves. On success, the chip lands face-up with a single foil flash. Haptic: `AppHaptics.refreshComplete` (UINotificationFeedbackGenerator.success).
- **Tab switch:** no transition motion (SwiftUI default is correct here), but `AppHaptics.tabSwitched` fires lightly.
- **Event detail open:** standard sheet present motion (the system motion is well-tuned and replacing it costs more than it gains). On appear, fire `AppHaptics.eventOpened` (light).

### Live countdown

- **Digit changes:** cross-fade only on the changing digit position, 0.08s. The tabular layout guarantees no layout shift. The full text never repaints; only the character that changed.
- **Tier escalation (green → amber → red):** color crossfade over 0.4s on the badge fill and text. Foil border thickens from 0.5pt → 1pt at the urgent tier and gains the animated brightness cycle described above.
- **At LR closed moment:** single subtle pulse (scale 1.0 → 1.06 → 1.0, 0.5s), then settle into grey "Closed" state. Haptic: `AppHaptics.lrClosed` (heavy impact, one-shot).

### Conflict banner

- Appears with a 0.18s fade-in, no slide. It's information; movement would draw too much attention. The neon-urgent fill itself is the signal.

### Things explicitly NOT animated

- Section card edges (foil hairlines are static).
- Buy-in badges (the chip dot doesn't pulse, jitter, or glint).
- The tab bar (no selection-indicator slide; the foil-mask state change is instant).
- The Played stats (numbers don't animate when they change — these are summary stats, not live values).

---

## 7 · Dark/light strategy

### Dark mode (primary)

- App background: `AppColor.rail.true` (`#0A0A0B`).
- Cards: `AppColor.rail.soft` (`#15161A`) with foil-muted hairline frame.
- Felt-green appears as **accent surfaces**, not the dominant background:
  - Live countdown card interior (felt PNG over felt.deep).
  - Star plaque fill (felt.dark with foil engraving).
  - Tab-bar background (felt PNG over rail.soft).
- Text: paper.cream (`#F5EFE6`) primary, with secondary/tertiary stepping down.
- Foil hairlines: foil.bright at 80% opacity.
- Neon used only on the running countdown card and the conflict banner.

**Reads as:** a broadcast tournament lower-third — dark, dense, information-first.

### Light mode (must work and meet contrast)

- App background: `AppColor.paper.cream` (`#F5EFE6`).
- Cards: pure white (`#FFFFFF`) with foil-muted hairline frame.
- Felt-green still appears as accent — but now as solid felt-green-on-cream patches, evoking "a printed structure sheet sitting on a felt table." The metaphor inverts: rather than felt being the canvas, felt is what's *under* the paper.
- Text: rail.true (`#0A0A0B`) on cream; rail.soft on white cards.
- Foil hairlines: foil.muted at full opacity (it reads correctly against light surfaces).
- Neon: same neon colors, but with a 1pt foil-bright border to maintain contrast against the lighter background.

**Reads as:** a paper tournament document — clean, official, print-design.

### Contrast (WCAG AA)

Tested against the matrix below at Phase 2 token finalization. Targets:
- Body text on background: AA Large (3:1) minimum; AA Normal (4.5:1) for `.bodyCopy`.
- Neon-on-rail and neon-on-cream: AA Large minimum (the neon is reserved for short, glanceable text — countdown digits, banner labels — which qualifies as "Large").
- Foil hairlines are not text and don't apply.

### Mode-switch behavior

Modes follow system; no in-app toggle. The transition uses SwiftUI's built-in animated color change. No bespoke motion required.

---

## What's next

If you approve this direction, Phase 2 produces the `DesignSystem/Tokens/` and `DesignSystem/Materials/` files exactly as specified:

```
ios/Sources/DesignSystem/
├── Tokens/
│   ├── AppColor.swift
│   ├── AppFont.swift
│   ├── AppSpacing.swift
│   ├── AppRadius.swift
│   ├── AppShadow.swift
│   └── AppHairline.swift
└── Materials/
    ├── AppTexture.swift
    └── AppHaptics.swift
```

Plus `Info.plist` registration of the three font families (Fraunces, Inter, JetBrains Mono — `.ttf` or `.otf` files added under `Sources/Resources/Fonts/`).

Existing `VenueColor.swift`, `GameCategoryStyle.swift`, and `Theme.swift` are refactored to delegate to the new tokens (not deleted; Phase 4 migrations will retire `Theme` if nothing references it).

Pending your approval, sign-off, or revisions before any of that lands.
