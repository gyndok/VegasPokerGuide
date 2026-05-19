import SwiftUI

struct VenueChip: View {
    let venue: Venue?
    var body: some View {
        if let v = venue {
            Text(v.displayName)
                .font(.caption2.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(VenueColor.color(forHex: v.colorHex).opacity(0.18))
                .foregroundStyle(VenueColor.color(forHex: v.colorHex))
                .clipShape(Capsule())
        }
    }
}
