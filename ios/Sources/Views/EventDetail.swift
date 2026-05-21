import SwiftUI

struct EventDetail: View {
    let tournament: Tournament
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var noteDraft: String = ""
    @State private var playedCashed: String = ""
    @State private var playedEntries: String = "1"
    @State private var playedHours: String = ""
    @State private var now: Date = Date()
    private let countdownTick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static let timePT: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/Los_Angeles")
        f.dateFormat = "h:mm a 'PT'"
        return f
    }()
    private static let timeLocal: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a zzz"
        return f
    }()

    var body: some View {
        let venue = state.venue(slug: tournament.venue)
        let venueAccent = AppColor.venueAccent(hex: venue?.colorHex ?? "#888888")
        let liveState = CountdownState.compute(startAt: tournament.startAtPT,
                                                lateRegClose: tournament.lateRegCloseAtPT,
                                                now: now)
        let isPlayed = state.playedRecords().contains(where: { $0.id == tournament.id })

        VStack(spacing: 0) {
            AppSheetHeader(title: tournament.eventName, onDismiss: { dismiss() })

            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    // Venue accent bar running the full leading edge of the content area
                    Rectangle()
                        .fill(venueAccent)
                        .frame(width: AppSpacing.venueBarWidth)

                    VStack(alignment: .leading, spacing: AppSpacing.l) {
                        headerChips(venue: venue)
                        eventTitle
                        statsGrid
                        detailsSection
                        if liveState.isVisible { liveCountdownCard(liveState: liveState) }
                        reEntryRow
                        actionsSection(venue: venue)
                        notesSection
                        playedSection(isPlayed: isPlayed)
                    }
                    .padding(AppSpacing.l)
                }
            }
            .background(AppColor.appBackground)
        }
        .background(AppColor.appBackground.ignoresSafeArea())
        .onReceive(countdownTick) { newNow in
            withAnimation(.easeInOut(duration: 0.12)) { now = newNow }
        }
        .onAppear {
            noteDraft = state.note(for: tournament.id) ?? ""
            if let existing = state.playedRecords().first(where: { $0.id == tournament.id }) {
                playedCashed = String(existing.cashed)
                playedEntries = String(existing.entries)
                if let h = existing.hoursPlayed, h > 0 {
                    playedHours = String(h)
                }
            }
        }
    }

    // MARK: - Header chips + star

    private func headerChips(venue: Venue?) -> some View {
        HStack(spacing: AppSpacing.s) {
            VenueChip(venue: venue)
            GameChip(category: tournament.gameCategory)
            Spacer()
            StarToggle(isOn: state.isStarred(tournament.id)) {
                Task {
                    AppHaptics.starToggled()
                    await state.toggleStar(tournament)
                }
            }
        }
    }

    // MARK: - Event title

    private var eventTitle: some View {
        Text(tournament.eventName)
            .font(AppFont.largeTitle)
            .foregroundStyle(AppColor.Text.primary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Stats grid (two columns × two rows)

    private var statsGrid: some View {
        VStack(spacing: AppSpacing.m) {
            HStack(spacing: AppSpacing.m) {
                statCell(label: "BUY-IN", buyInBadge: true)
                statCell(label: "GUARANTEE", value: tournament.guaranteeUSD.map { "$\($0.formatted(.number))" } ?? "—")
            }
            HStack(spacing: AppSpacing.m) {
                statCell(label: "STARTS", value: timeString(tournament.startAtPT))
                statCell(label: "LATE REG CLOSES", value: timeString(tournament.lateRegCloseAtPT))
            }
        }
    }

    @ViewBuilder
    private func statCell(label: String, value: String = "", buyInBadge: Bool = false) -> some View {
        SectionCard(title: label) {
            if buyInBadge {
                HStack {
                    BuyInBadge(amountUSD: tournament.buyInUSD)
                        .font(AppFont.buyInLarge)  // upsize the value
                    Spacer()
                }
            } else {
                Text(value)
                    .font(AppFont.buyInLarge)
                    .monospacedDigit()
                    .foregroundStyle(AppColor.Text.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    // MARK: - Wizardofviz enrichment details section

    @ViewBuilder
    private var detailsSection: some View {
        let hasAny = tournament.startingStack != nil
            || tournament.levelMinutes != nil
            || tournament.handed != nil
            || tournament.rakeUSD != nil
        if hasAny {
            VStack(spacing: AppSpacing.m) {
                HStack(spacing: AppSpacing.m) {
                    detailCell(label: "STARTING STACK",
                               value: tournament.startingStack.map { $0.formatted(.number) } ?? "—")
                    detailCell(label: "LEVEL LENGTH",
                               value: tournament.levelMinutes ?? "—")
                }
                HStack(spacing: AppSpacing.m) {
                    detailCell(label: "HANDED",
                               value: tournament.handed.map { "\($0)-max" } ?? "—")
                    detailCell(label: "RAKE",
                               value: rakeText)
                }
            }
        }
    }

    private var rakeText: String {
        guard let usd = tournament.rakeUSD else { return "—" }
        if let pct = tournament.rakePct {
            return "$\(Int(usd)) (\(Int(pct * 100))%)"
        }
        return "$\(Int(usd))"
    }

    @ViewBuilder
    private func detailCell(label: String, value: String) -> some View {
        SectionCard(title: label) {
            Text(value)
                .font(AppFont.buyInLarge)
                .monospacedDigit()
                .foregroundStyle(AppColor.Text.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Live countdown card (showpiece)

    private func liveCountdownCard(liveState: CountdownState) -> some View {
        VStack(spacing: AppSpacing.s) {
            Text("LATE REG CLOSES IN")
                .font(AppFont.sectionLabel)
                .tracking(2.0)
                .foregroundStyle(AppColor.Foil.bright)
            Text(liveState.text)
                .font(AppFont.countdownLarge)
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .foregroundStyle(textColor(for: liveState.tier))
        }
        .padding(.vertical, AppSpacing.l)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTexture.feltSurface().clipShape(RoundedRectangle(cornerRadius: AppRadius.card)))
        .foilGradientBorder(cornerRadius: AppRadius.card, width: 1.2)
    }

    private func textColor(for tier: CountdownState.Tier) -> Color {
        switch tier {
        case .green: return AppColor.State.live
        case .amber: return AppColor.State.warning
        case .red:   return AppColor.State.urgent
        case .closed: return AppColor.State.closed
        case .notRunning, .unknown: return AppColor.Text.tertiary
        }
    }

    // MARK: - Re-entry row

    private var reEntryRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
            Text("RE-ENTRY")
                .font(AppFont.sectionLabel)
                .tracking(1.4)
                .foregroundStyle(AppColor.Text.secondary)
            Text(ReEntryFormatter.format(tournament.reEntry))
                .font(AppFont.bodyCopy)
                .foregroundStyle(AppColor.Text.primary)
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private func actionsSection(venue: Venue?) -> some View {
        VStack(spacing: AppSpacing.s) {
            // Prefer per-event structure URL when available; fall back to the venue-wide URL.
            let pdfURLString = tournament.structurePDFURL?.isEmpty == false
                ? tournament.structurePDFURL
                : venue?.structurePDFURL
            if let urlStr = pdfURLString, let url = URL(string: urlStr), !urlStr.isEmpty {
                Link(destination: url) {
                    AppButtonLikeRow(title: "OPEN STRUCTURE SHEET", systemImage: "doc.text", style: .secondary)
                }
                .buttonStyle(.plain)
            }
            if let venue {
                AppButton("DIRECTIONS — \(venue.displayName.uppercased())",
                          systemImage: "map",
                          style: .secondary) {
                    MapsLauncher.openDirections(to: venue)
                }
            }
            AppButton("ADD TO CALENDAR", systemImage: "calendar.badge.plus", style: .secondary) {
                Task { try? await CalendarExporter().add(tournament: tournament, venue: venue) }
            }
            AppButton(
                state.isStarred(tournament.id) ? "NOTIFICATION SCHEDULED (30 MIN BEFORE LR)" : "NOTIFY 30 MIN BEFORE LR",
                systemImage: state.isStarred(tournament.id) ? "bell.badge.fill" : "bell.badge",
                style: state.isStarred(tournament.id) ? .primary : .secondary
            ) {
                Task {
                    AppHaptics.starToggled()
                    await state.toggleStar(tournament)
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("NOTES")
                .font(AppFont.sectionLabel)
                .tracking(1.4)
                .foregroundStyle(AppColor.Text.secondary)
            HStack(alignment: .top, spacing: 0) {
                Rectangle()
                    .fill(AppColor.Foil.bright)
                    .frame(width: 2)
                TextEditor(text: $noteDraft)
                    .font(AppFont.notesBody)
                    .foregroundStyle(AppColor.Text.primary)
                    .scrollContentBackground(.hidden)
                    .background(AppColor.cardSurface)
                    .frame(minHeight: 80)
                    .padding(.leading, AppSpacing.s)
                    .onChange(of: noteDraft) { _, new in
                        state.setNote(new, for: tournament.id)
                    }
            }
            .background(AppColor.cardSurface)
            .foilBorder(cornerRadius: AppRadius.card, width: 0.5, opacity: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        }
    }

    // MARK: - Played

    private func playedSection(isPlayed: Bool) -> some View {
        SectionCard(title: "PLAYED LOG") {
            VStack(spacing: AppSpacing.s) {
                AppToggle(title: "I played this tournament", isOn: Binding(
                    get: { isPlayed },
                    set: { on in
                        if on {
                            state.recordPlayed(id: tournament.id,
                                               buyIn: tournament.buyInUSD ?? 0,
                                               cashed: Int(playedCashed) ?? 0,
                                               entries: max(1, Int(playedEntries) ?? 1),
                                               hoursPlayed: Double(playedHours))
                        } else {
                            state.unrecordPlayed(id: tournament.id)
                        }
                    }
                ))
                playedInputRow(label: "CASHED", placeholder: "0", text: $playedCashed, keyboardType: .numberPad)
                    .onChange(of: playedCashed) { _, new in
                        if isPlayed {
                            state.recordPlayed(id: tournament.id,
                                               buyIn: tournament.buyInUSD ?? 0,
                                               cashed: Int(new) ?? 0,
                                               entries: max(1, Int(playedEntries) ?? 1),
                                               hoursPlayed: Double(playedHours))
                        }
                    }
                playedInputRow(label: "ENTRIES", placeholder: "1", text: $playedEntries, keyboardType: .numberPad)
                    .onChange(of: playedEntries) { _, new in
                        if isPlayed {
                            state.recordPlayed(id: tournament.id,
                                               buyIn: tournament.buyInUSD ?? 0,
                                               cashed: Int(playedCashed) ?? 0,
                                               entries: max(1, Int(new) ?? 1),
                                               hoursPlayed: Double(playedHours))
                        }
                    }
                playedInputRow(label: "HOURS", placeholder: "0.0", text: $playedHours, keyboardType: .decimalPad)
                    .onChange(of: playedHours) { _, new in
                        if isPlayed {
                            state.recordPlayed(id: tournament.id,
                                               buyIn: tournament.buyInUSD ?? 0,
                                               cashed: Int(playedCashed) ?? 0,
                                               entries: max(1, Int(playedEntries) ?? 1),
                                               hoursPlayed: Double(new))
                        }
                    }
            }
        }
    }

    private func playedInputRow(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        HStack {
            Text(label)
                .font(AppFont.sectionLabel)
                .tracking(1.4)
                .foregroundStyle(AppColor.Text.secondary)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .font(AppFont.buyIn)
                .monospacedDigit()
                .foregroundStyle(AppColor.Text.primary)
                .frame(maxWidth: 120)
                .padding(.horizontal, AppSpacing.s)
                .padding(.vertical, 6)
                .background(AppColor.cardSurface, in: RoundedRectangle(cornerRadius: AppRadius.badge))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.badge)
                    .strokeBorder(AppColor.Foil.muted, lineWidth: 0.5))
        }
    }

    // MARK: - Formatting helpers

    private func timeString(_ date: Date?) -> String {
        guard let d = date else { return "—" }
        let pt = Self.timePT.string(from: d)
        let local = Self.timeLocal.string(from: d)
        return local == pt ? pt : pt
    }
}

/// Wraps an `AppButton`-styled row inside a Link. Lets a Link present as our chip-shaped button.
/// Tap behavior comes from the Link itself; this view only renders the label.
private struct AppButtonLikeRow: View {
    let title: String
    let systemImage: String?
    let style: AppButton.Style

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            if let systemImage {
                Image(systemName: systemImage).font(.system(size: 14, weight: .medium))
            }
            Text(title)
                .font(AppFont.sectionLabel)
                .tracking(1.2)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, AppSpacing.l)
        .padding(.vertical, AppSpacing.m)
        .frame(maxWidth: .infinity)
        .background(background, in: RoundedRectangle(cornerRadius: AppRadius.chip))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.chip)
            .strokeBorder(borderColor, lineWidth: 0.8))
    }

    private var foreground: Color { AppColor.Foil.bright }
    private var background: Color { AppColor.Foil.bright.opacity(0.08) }
    private var borderColor: Color { AppColor.Foil.bright.opacity(0.6) }
}
