import SwiftUI

/// One tournament row. Uses the Felt & Foil design system: VenueChip, GameChip,
/// BuyInBadge with chip-tier color dot, foil-tinted star marker, CountdownBadge.
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
        HStack(alignment: .top, spacing: AppSpacing.m) {
            // Venue accent bar on the leading edge
            Rectangle()
                .fill(AppColor.venueAccent(hex: venue?.colorHex ?? "#888888"))
                .frame(width: AppSpacing.venueBarWidth)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Chips row
                HStack(spacing: AppSpacing.xs) {
                    VenueChip(venue: venue)
                    GameChip(category: tournament.gameCategory)
                    if isStarred {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppColor.Foil.bright)
                    }
                    Spacer(minLength: 0)
                }

                // Event name (display font)
                Text(tournament.eventName)
                    .font(AppFont.eventName)
                    .foregroundStyle(AppColor.Text.primary)
                    .lineLimit(2)

                // Bottom row: time · buy-in · countdown badge
                HStack(spacing: AppSpacing.m) {
                    if let start = tournament.startAtPT {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(AppColor.Text.tertiary)
                            Text(EventRow.timeFmt.string(from: start))
                                .font(AppFont.timestamp)
                                .foregroundStyle(AppColor.Text.secondary)
                        }
                    }
                    BuyInBadge(amountUSD: tournament.buyInUSD)
                    Spacer(minLength: 0)
                    CountdownBadge(startAt: tournament.startAtPT, lateRegClose: tournament.lateRegCloseAtPT)
                }
            }
        }
        .padding(.vertical, AppSpacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts: [String] = []
        if let venue { parts.append(venue.displayName) }
        parts.append(tournament.eventName)
        if let buy = tournament.buyInUSD { parts.append("$\(buy) buy-in") }
        if let start = tournament.startAtPT {
            parts.append("starts \(EventRow.timeFmt.string(from: start))")
        }
        if isStarred { parts.append("starred") }
        return parts.joined(separator: ", ")
    }
}
