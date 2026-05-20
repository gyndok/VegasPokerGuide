import SwiftUI

/// Adapter that delegates to AppColor.venueAccent for a hex string.
/// Kept for back-compat with existing call sites (EventRow, VenueChip).
enum VenueColor {
    static func color(forHex hex: String) -> Color {
        AppColor.venueAccent(hex: hex)
    }
}
