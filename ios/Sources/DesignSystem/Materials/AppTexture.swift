import SwiftUI

/// Surface texture helpers for the Felt & Foil design system.
///
/// Note: the felt-noise PNG asset is not yet shipped. `feltSurface` currently renders
/// a 3-stop gradient placeholder. Swap in a tiled PNG (`Image("felt-texture-dark")`)
/// when the asset is produced.
enum AppTexture {

    /// Felt surface gradient placeholder. Apply to backgrounds of tab bar, sheet headers,
    /// and the live countdown card interior. NOT for row interiors (flat color there).
    @ViewBuilder
    static func feltSurface() -> some View {
        ZStack {
            AppColor.Felt.deep
            LinearGradient(
                colors: [
                    AppColor.Felt.dark.opacity(0.9),
                    AppColor.Felt.deep,
                    AppColor.Felt.dark.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Subtle radial vignette
            RadialGradient(
                colors: [Color.clear, AppColor.Felt.deep.opacity(0.6)],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
        }
    }

    /// Animated foil-gradient overlay. Use as a card border that subtly cycles brightness.
    /// Apply via `.foilGradientBorder(cornerRadius:)`.
    static func foilGradient(brightness: Double = 1.0) -> LinearGradient {
        LinearGradient(
            colors: [
                AppColor.Foil.bright.opacity(brightness),
                AppColor.Foil.muted.opacity(brightness * 0.7),
                AppColor.Foil.bright.opacity(brightness)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Applies a foil-gradient border to a view. Used on the live countdown card.
    func foilGradientBorder(cornerRadius: CGFloat = AppRadius.card, width: CGFloat = 1, brightness: Double = 1.0) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(AppTexture.foilGradient(brightness: brightness), lineWidth: width)
        )
    }
}
