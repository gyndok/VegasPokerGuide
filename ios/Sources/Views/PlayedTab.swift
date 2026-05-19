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
            List {
                Section {
                    let totals = state.playedTotals()
                    HStack {
                        stat("Entries", value: "\(totals.count)")
                        stat("$ In", value: "$\(totals.totalIn.formatted(.number))")
                        stat("$ Cashed", value: "$\(totals.totalCashed.formatted(.number))")
                        stat("Net", value: "$\(totals.net.formatted(.number))")
                    }
                }
                ForEach(state.playedRecords().sorted(by: { $0.recordedAt > $1.recordedAt }), id: \.id) { r in
                    let t = state.tournaments.first(where: { $0.id == r.id })
                    HStack {
                        VStack(alignment: .leading) {
                            Text(t?.eventName ?? r.id).font(.body.weight(.medium))
                            Text(Self.dayFmt.string(from: r.recordedAt)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("-$\(r.buyIn)").foregroundStyle(.red).font(.caption)
                            Text("+$\(r.cashed)").foregroundStyle(.green).font(.caption)
                        }
                    }
                }
                if state.playedRecords().isEmpty {
                    ContentUnavailableView("Nothing played yet",
                                            systemImage: "checkmark.seal",
                                            description: Text("Mark a tournament as Played from its detail screen."))
                }
            }
            .navigationTitle("Played")
        }
    }

    private func stat(_ label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.body.monospacedDigit())
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
