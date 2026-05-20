import SwiftUI

/// Pill chip showing a venue's display name, accented with that venue's curated color
/// and finished with a foil hairline edge.
struct VenueChip: View {
    let venue: Venue?

    var body: some View {
        if let v = venue {
            let accent = AppColor.venueAccent(hex: v.colorHex)
            Text(v.displayName)
                .font(AppFont.sectionLabel)
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(accent)
                .padding(.horizontal, AppSpacing.s)
                .padding(.vertical, AppSpacing.xs)
                .background(accent.opacity(0.14), in: Capsule())
                .foilBorder(cornerRadius: 999, width: 0.5, opacity: 0.5)
        }
    }
}

#Preview("VenueChip") {
    let v = Venue(slug: "venetian", displayName: "Venetian",
                  seriesName: "Venetian DeepStack", seriesDates: "...",
                  address: "", mapsURL: "", website: "",
                  structurePDFURL: "", colorHex: "#8B0000")
    let long = Venue(slug: "wsop", displayName: "WSOP Paris / Horseshoe",
                     seriesName: "World Series", seriesDates: "...",
                     address: "", mapsURL: "", website: "",
                     structurePDFURL: "", colorHex: "#C8102E")

    VStack(spacing: 24) {
        VStack(spacing: 12) {
            Text("Light").font(.caption)
            HStack { VenueChip(venue: v); VenueChip(venue: long) }
        }
        .padding()
        .background(AppColor.Paper.cream)
        .environment(\.colorScheme, .light)

        VStack(spacing: 12) {
            Text("Dark").font(.caption)
            HStack { VenueChip(venue: v); VenueChip(venue: long) }
        }
        .padding()
        .background(AppColor.Rail.true)
        .environment(\.colorScheme, .dark)
    }
}
