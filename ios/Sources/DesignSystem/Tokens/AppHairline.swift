import SwiftUI

/// Foil/brass hairlines — the pervasive "this is custom" signal.
enum AppHairline {

    /// 0.5pt horizontal foil line. Use as a divider beneath day headers, between cells, etc.
    static func divider(opacity: Double = 0.8) -> some View {
        Rectangle()
            .fill(AppColor.Foil.bright.opacity(opacity))
            .frame(height: 0.5)
            .allowsHitTesting(false)
    }

    /// Vertical foil hairline. Use as separator between cells in a stat grid.
    static func vertical(opacity: Double = 0.6, height: CGFloat? = nil) -> some View {
        Rectangle()
            .fill(AppColor.Foil.bright.opacity(opacity))
            .frame(width: 0.5)
            .frame(height: height)
            .allowsHitTesting(false)
    }

    /// Foil hairline used as a border on cards. Apply via `.foilBorder()`.
    static func borderColor(animated: Bool = false) -> Color {
        AppColor.Foil.bright.opacity(animated ? 1.0 : 0.8)
    }
}

extension View {
    /// Adds a foil hairline border to a view, sized to its bounds with the given corner radius.
    func foilBorder(cornerRadius: CGFloat = AppRadius.card, width: CGFloat = 0.5, opacity: Double = 0.8) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(AppColor.Foil.bright.opacity(opacity), lineWidth: width)
        )
    }
}
