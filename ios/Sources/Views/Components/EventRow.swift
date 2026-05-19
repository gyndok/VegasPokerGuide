import SwiftUI

struct EventRow: View {
    let tournament: Tournament
    let venue: Venue?
    let isStarred: Bool

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/Los_Angeles")
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(VenueColor.color(forHex: venue?.colorHex ?? "#888888"))
                .frame(width: Theme.venueBarWidth)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    VenueChip(venue: venue)
                    GameCategoryChip(category: tournament.gameCategory)
                    if isStarred {
                        Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption2)
                    }
                }
                Text(tournament.eventName).font(.body.weight(.medium)).lineLimit(1)
                HStack(spacing: 12) {
                    if let start = tournament.startAtPT {
                        Label(Self.timeFmt.string(from: start), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let buyIn = tournament.buyInUSD {
                        Text("$\(buyIn)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    CountdownBadge(lateRegClose: tournament.lateRegCloseAtPT)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
