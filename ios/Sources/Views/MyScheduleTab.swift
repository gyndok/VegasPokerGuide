import SwiftUI

struct MyScheduleTab: View {
    @Environment(AppState.self) private var state
    @State private var selected: Tournament? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                screenHeader

                if state.starredTournaments.isEmpty {
                    AppEmptyState(illustration: .fadedChips,
                                  title: "No starred events",
                                  message: "Tap the star on any event in the Schedule tab to plan your trip.")
                } else {
                    listBody
                }
            }
            .background(AppColor.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selected) { t in
                EventDetail(tournament: t).environment(state)
            }
        }
    }

    // MARK: - Header

    private var screenHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("MY TABLE")
                    .font(AppFont.sectionLabel)
                    .tracking(2.0)
                    .foregroundStyle(AppColor.Foil.bright)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.top, AppSpacing.m)
            HStack {
                Text("My Schedule")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.Text.primary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.s)
            AppHairline.divider(opacity: 0.6)
        }
    }

    // MARK: - List body

    private var listBody: some View {
        ScrollView {
            VStack(spacing: AppSpacing.l) {
                summaryCard
                if !state.conflicts.isEmpty {
                    conflictBanner
                }
                ForEach(groupedByDay(), id: \.0) { day, items in
                    VStack(alignment: .leading, spacing: 0) {
                        AppDayHeader(date: day)
                            .padding(.horizontal, AppSpacing.l)
                        VStack(spacing: 0) {
                            ForEach(items) { t in
                                Button {
                                    selected = t
                                    AppHaptics.eventOpened()
                                } label: {
                                    EventRow(tournament: t,
                                             venue: state.venue(slug: t.venue),
                                             isStarred: true)
                                        .padding(.horizontal, AppSpacing.l)
                                        .background(AppColor.cardSurface)
                                        .overlay(alignment: .bottom) {
                                            AppHairline.divider(opacity: 0.35)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.appBackground)
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        SectionCard(title: "STARRED EVENTS") {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(state.starredTournaments.count)")
                        .font(AppFont.countdownLarge)
                        .monospacedDigit()
                        .foregroundStyle(AppColor.Text.primary)
                    Text(state.starredTournaments.count == 1 ? "event" : "events")
                        .font(AppFont.meta)
                        .foregroundStyle(AppColor.Text.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("$\(state.starredTotalBuyIn.formatted(.number))")
                        .font(AppFont.buyInLarge)
                        .monospacedDigit()
                        .foregroundStyle(AppColor.Foil.bright)
                    Text("TOTAL BUY-IN")
                        .font(AppFont.sectionLabel)
                        .tracking(1.4)
                        .foregroundStyle(AppColor.Text.secondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.l)
    }

    // MARK: - Conflict banner

    private var conflictBanner: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack(spacing: AppSpacing.s) {
                ConflictDiamond()
                    .fill(AppColor.Neon.urgent)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Text("!")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(AppColor.Rail.true)
                    )
                Text("CONFLICTS")
                    .font(AppFont.sectionLabel)
                    .tracking(1.6)
                    .foregroundStyle(AppColor.Neon.urgent)
                Spacer()
            }
            ForEach(0..<state.conflicts.count, id: \.self) { i in
                let (a, b) = state.conflicts[i]
                if let ta = lookup(a), let tb = lookup(b) {
                    Text("\(ta.eventName) (\(ta.venue.capitalized)) overlaps with \(tb.eventName) (\(tb.venue.capitalized))")
                        .font(AppFont.bodyCopy)
                        .foregroundStyle(AppColor.Text.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(AppSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.Neon.urgent.opacity(0.12), in: RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.card)
            .strokeBorder(AppColor.Neon.urgent.opacity(0.7), lineWidth: 1))
        .padding(.horizontal, AppSpacing.l)
    }

    private func lookup(_ id: String) -> Tournament? {
        state.starredTournaments.first(where: { $0.id == id })
    }

    private func groupedByDay() -> [(Date, [Tournament])] {
        let cal = Calendar(identifier: .gregorian)
        var byDay: [Date: [Tournament]] = [:]
        for t in state.starredTournaments {
            byDay[cal.startOfDay(for: t.datePT), default: []].append(t)
        }
        return byDay.keys.sorted().map { ($0, byDay[$0]!) }
    }
}

/// Diamond shape for the conflict-banner glyph.
private struct ConflictDiamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}
