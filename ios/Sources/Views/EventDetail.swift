import SwiftUI

struct EventDetail: View {
    let tournament: Tournament
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var noteDraft: String = ""
    @State private var playedCashed: String = ""
    @State private var notifyEnabled: Bool = false

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

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 8) {
                        VenueChip(venue: venue)
                        GameCategoryChip(category: tournament.gameCategory)
                        Spacer()
                        Button {
                            Task { await state.toggleStar(tournament) }
                        } label: {
                            Image(systemName: state.isStarred(tournament.id) ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.title3)
                        }
                    }
                    Text(tournament.eventName).font(.title2.weight(.semibold))

                    // Two-column stats
                    HStack(alignment: .top, spacing: 16) {
                        statColumn("Buy-in", value: tournament.buyInUSD.map { "$\($0)" } ?? "—")
                        statColumn("Guarantee", value: tournament.guaranteeUSD.map { "$\($0.formatted(.number))" } ?? "—")
                    }
                    HStack(alignment: .top, spacing: 16) {
                        statColumn("Starts", value: timeString(tournament.startAtPT))
                        statColumn("Late reg closes", value: timeString(tournament.lateRegCloseAtPT))
                    }

                    // Live countdown
                    if tournament.lateRegCloseAtPT != nil {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Late reg closes in").font(.caption).foregroundStyle(.secondary)
                                CountdownBadge(lateRegClose: tournament.lateRegCloseAtPT)
                                    .scaleEffect(1.6)
                                    .padding(.vertical, 6)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }

                    // Re-entry
                    Text("Re-entry: \(ReEntryFormatter.format(tournament.reEntry))")
                        .font(.body)

                    // Actions
                    VStack(spacing: 10) {
                        if let urlStr = venue?.structurePDFURL, let url = URL(string: urlStr), !urlStr.isEmpty {
                            Link(destination: url) {
                                Label("Open Structure Sheet (PDF)", systemImage: "doc.text")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        if let venue {
                            Button {
                                MapsLauncher.openDirections(to: venue)
                            } label: {
                                Label("Directions to \(venue.displayName)", systemImage: "map")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        Button {
                            Task { try? await CalendarExporter().add(tournament: tournament, venue: venue) }
                        } label: {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    // Notes
                    Divider()
                    Text("Notes").font(.headline)
                    TextEditor(text: $noteDraft)
                        .frame(minHeight: 60)
                        .padding(6)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .onChange(of: noteDraft) { _, new in state.setNote(new, for: tournament.id) }

                    // Played
                    Divider()
                    Toggle("Played this", isOn: Binding(
                        get: { state.playedRecords().contains(where: { $0.id == tournament.id }) },
                        set: { on in
                            if on { state.recordPlayed(id: tournament.id, buyIn: tournament.buyInUSD ?? 0, cashed: Int(playedCashed) ?? 0) }
                            else { state.unrecordPlayed(id: tournament.id) }
                        }
                    ))
                    HStack {
                        Text("Cashed")
                        TextField("0", text: $playedCashed)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: playedCashed) { _, new in
                                if state.playedRecords().contains(where: { $0.id == tournament.id }) {
                                    state.recordPlayed(id: tournament.id, buyIn: tournament.buyInUSD ?? 0, cashed: Int(new) ?? 0)
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                noteDraft = state.note(for: tournament.id) ?? ""
                if let existing = state.playedRecords().first(where: { $0.id == tournament.id }) {
                    playedCashed = String(existing.cashed)
                }
            }
        }
    }

    private func statColumn(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.body.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func timeString(_ date: Date?) -> String {
        guard let d = date else { return "—" }
        let pt = Self.timePT.string(from: d)
        let local = Self.timeLocal.string(from: d)
        return local == pt ? pt : "\(pt)  (\(local))"
    }
}
