import SwiftUI

struct PlayedTab: View {
    @Environment(AppState.self) private var state
    @State private var editingTournament: Tournament? = nil

    private static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                screenHeader

                if state.playedRecords().isEmpty {
                    AppEmptyState(illustration: .foldedCard,
                                  title: "Nothing played yet",
                                  message: "Mark a tournament as Played from its detail screen.")
                } else {
                    body_
                }
            }
            .background(AppColor.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $editingTournament) { t in
                EventDetail(tournament: t).environment(state)
            }
        }
    }

    // MARK: - Header

    private var screenHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PLAYED LOG")
                    .font(AppFont.sectionLabel)
                    .tracking(2.0)
                    .foregroundStyle(AppColor.Foil.bright)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.top, AppSpacing.m)
            HStack {
                Text("Played")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.Text.primary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.s)
            AppHairline.divider(opacity: 0.6)
        }
    }

    // MARK: - Body

    private var body_: some View {
        VStack(spacing: 0) {
            summaryCard
                .padding(.bottom, AppSpacing.l)
            logList
        }
        .background(AppColor.appBackground)
    }

    // MARK: - Summary card (2-column × 3-row grid)

    private var summaryCard: some View {
        let totals = state.playedTotals()
        return SectionCard(title: "TOURNAMENT SUMMARY") {
            let columns = [GridItem(.flexible(), spacing: AppSpacing.m),
                           GridItem(.flexible(), spacing: AppSpacing.m)]
            LazyVGrid(columns: columns, alignment: .center, spacing: AppSpacing.m) {
                statCell(label: "ENTRIES",  value: "\(totals.totalEntries)",                    tone: .neutral)
                statCell(label: "$ IN",     value: "$\(totals.totalIn.formatted(.number))",    tone: .neutral)
                statCell(label: "$ OUT",    value: "$\(totals.totalCashed.formatted(.number))", tone: .cashed)
                statCell(label: "NET",      value: signed(totals.net),                         tone: totals.net >= 0 ? .cashed : .lost)
                statCell(label: "ROI",      value: roiString(totals.roi),                      tone: roiTone(totals.roi))
                statCell(label: "HOURLY",   value: hourlyString(totals.hourlyRate),             tone: hourlyTone(totals.hourlyRate))
            }
        }
        .padding(.horizontal, AppSpacing.l)
    }

    private enum Tone { case neutral, cashed, lost }

    private func statCell(label: String, value: String, tone: Tone) -> some View {
        VStack(alignment: .center, spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.buyIn)
                .monospacedDigit()
                .foregroundStyle(color(for: tone))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(AppFont.sectionLabel)
                .tracking(1.2)
                .foregroundStyle(AppColor.Text.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xs)
    }

    private func color(for tone: Tone) -> Color {
        switch tone {
        case .neutral: return AppColor.Text.primary
        case .cashed:  return AppColor.Chip.green
        case .lost:    return AppColor.Chip.red
        }
    }

    private func signed(_ amount: Int) -> String {
        let prefix = amount >= 0 ? "+" : "-"
        return "\(prefix)$\(abs(amount).formatted(.number))"
    }

    private func roiString(_ roi: Double?) -> String {
        guard let roi else { return "—" }
        let percent = Int((roi * 100).rounded())
        let prefix = percent >= 0 ? "+" : ""
        return "\(prefix)\(percent)%"
    }

    private func roiTone(_ roi: Double?) -> Tone {
        guard let roi else { return .neutral }
        return roi >= 0 ? .cashed : .lost
    }

    private func hourlyString(_ rate: Double?) -> String {
        guard let rate, rate != 0 else { return "—" }
        let prefix = rate >= 0 ? "+" : "-"
        return "\(prefix)$\(Int(abs(rate).rounded()))/hr"
    }

    private func hourlyTone(_ rate: Double?) -> Tone {
        guard let rate, rate != 0 else { return .neutral }
        return rate >= 0 ? .cashed : .lost
    }

    // MARK: - Log list

    private var logList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("RECORDS")
                    .font(AppFont.sectionLabel)
                    .tracking(1.4)
                    .foregroundStyle(AppColor.Text.secondary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.s)

            let records = state.playedRecords().sorted(by: { $0.recordedAt > $1.recordedAt })
            List {
                ForEach(records, id: \.id) { r in
                    let t = state.tournaments.first(where: { $0.id == r.id })
                    HStack(alignment: .center, spacing: AppSpacing.m) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t?.eventName ?? r.id)
                                .font(AppFont.eventName)
                                .foregroundStyle(AppColor.Text.primary)
                                .lineLimit(1)
                            Text(Self.dayFmt.string(from: r.recordedAt))
                                .font(AppFont.timestamp)
                                .foregroundStyle(AppColor.Text.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            // $ IN line
                            if r.entries > 1 {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("-$\((r.buyIn * r.entries).formatted(.number))")
                                        .font(AppFont.buyIn)
                                        .monospacedDigit()
                                        .foregroundStyle(AppColor.Chip.red)
                                    Text("(\(r.entries)×)")
                                        .font(AppFont.meta)
                                        .foregroundStyle(AppColor.Text.tertiary)
                                }
                            } else {
                                Text("-$\(r.buyIn.formatted(.number))")
                                    .font(AppFont.buyIn)
                                    .monospacedDigit()
                                    .foregroundStyle(AppColor.Chip.red)
                            }
                            // $ OUT line
                            Text("+$\(r.cashed.formatted(.number))")
                                .font(AppFont.buyIn)
                                .monospacedDigit()
                                .foregroundStyle(AppColor.Chip.green)
                            // Hours annotation
                            if let h = r.hoursPlayed, h > 0 {
                                Text("\(formatHours(h))h")
                                    .font(AppFont.meta)
                                    .foregroundStyle(AppColor.Text.tertiary)
                            }
                        }
                    }
                    .appRowStyle()
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            AppHaptics.starToggled()
                            state.unrecordPlayed(id: r.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        if let tournament = t {
                            Button {
                                editingTournament = tournament
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(AppColor.Foil.bright)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColor.appBackground)
        }
    }

    private func formatHours(_ h: Double) -> String {
        if h == h.rounded() {
            return "\(Int(h))"
        }
        return String(format: "%.1f", h)
    }
}
