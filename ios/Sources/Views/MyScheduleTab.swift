import SwiftUI

struct MyScheduleTab: View {
    @Environment(AppState.self) private var state
    @State private var selected: Tournament? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SummaryCard(count: state.starredTournaments.count, total: state.starredTotalBuyIn)
                }
                if !state.conflicts.isEmpty {
                    Section {
                        ConflictBanner(conflicts: state.conflicts, lookup: { id in
                            state.starredTournaments.first(where: { $0.id == id })
                        })
                    }
                }
                ForEach(groupedByDay(), id: \.0) { day, items in
                    Section(header: DayHeader(date: day)) {
                        ForEach(items) { t in
                            Button {
                                selected = t
                            } label: {
                                EventRow(tournament: t,
                                         venue: state.venue(slug: t.venue),
                                         isStarred: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                if state.starredTournaments.isEmpty {
                    ContentUnavailableView("No starred events",
                                            systemImage: "star",
                                            description: Text("Tap the star on any event in the Schedule tab to plan it."))
                }
            }
            .listStyle(.plain)
            .navigationTitle("My Schedule")
            .sheet(item: $selected) { t in
                EventDetail(tournament: t).environment(state)
            }
        }
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

private struct SummaryCard: View {
    let count: Int
    let total: Int
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(count) starred events").font(.headline)
                Text("Total buy-in: $\(total.formatted(.number))").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct ConflictBanner: View {
    let conflicts: [(String, String)]
    let lookup: (String) -> Tournament?
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<conflicts.count, id: \.self) { i in
                let (a, b) = conflicts[i]
                if let ta = lookup(a), let tb = lookup(b) {
                    Label("\(ta.eventName) (\(ta.venue.capitalized)) overlaps with \(tb.eventName) (\(tb.venue.capitalized))",
                          systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.footnote)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
