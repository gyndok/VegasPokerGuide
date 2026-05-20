import SwiftUI

struct PlayedTab: View {
    @Environment(AppState.self) private var state

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
        ScrollView {
            VStack(spacing: AppSpacing.l) {
                summaryCard
                logList
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.appBackground)
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        let totals = state.playedTotals()
        return SectionCard(title: "TOURNAMENT SUMMARY") {
            HStack(alignment: .top, spacing: 0) {
                statCell(label: "ENTRIES", value: "\(totals.count)", tone: .neutral)
                AppHairline.vertical().frame(height: 48)
                statCell(label: "$ IN", value: "$\(totals.totalIn.formatted(.number))", tone: .neutral)
                AppHairline.vertical().frame(height: 48)
                statCell(label: "$ CASHED", value: "$\(totals.totalCashed.formatted(.number))", tone: .cashed)
                AppHairline.vertical().frame(height: 48)
                statCell(label: "NET", value: signed(totals.net), tone: totals.net >= 0 ? .cashed : .lost)
            }
        }
        .padding(.horizontal, AppSpacing.l)
    }

    private enum Tone { case neutral, cashed, lost }

    private func statCell(label: String, value: String, tone: Tone) -> some View {
        VStack(alignment: .center, spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.stat)
                .monospacedDigit()
                .foregroundStyle(color(for: tone))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(AppFont.sectionLabel)
                .tracking(1.2)
                .foregroundStyle(AppColor.Text.tertiary)
        }
        .frame(maxWidth: .infinity)
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

            VStack(spacing: 0) {
                let records = state.playedRecords().sorted(by: { $0.recordedAt > $1.recordedAt })
                ForEach(Array(records.enumerated()), id: \.element.id) { index, r in
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
                            Text("-$\(r.buyIn.formatted(.number))")
                                .font(AppFont.buyIn)
                                .monospacedDigit()
                                .foregroundStyle(AppColor.Chip.red)
                            Text("+$\(r.cashed.formatted(.number))")
                                .font(AppFont.buyIn)
                                .monospacedDigit()
                                .foregroundStyle(AppColor.Chip.green)
                        }
                    }
                    .padding(.horizontal, AppSpacing.l)
                    .padding(.vertical, AppSpacing.m)
                    .background(AppColor.cardSurface)
                    .overlay(alignment: .bottom) {
                        if index < records.count - 1 { AppHairline.divider(opacity: 0.35) }
                    }
                }
            }
        }
    }
}
