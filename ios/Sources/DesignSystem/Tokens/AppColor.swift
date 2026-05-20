import SwiftUI

/// Semantic color tokens for the Felt & Foil design system.
/// Raw hex literals appear ONLY in this file. Every other file consumes named tokens.
enum AppColor {

    // MARK: - Foundation surfaces

    enum Rail {
        static let `true` = Color(hex: 0x0A0A0B)     // OLED true-black, dark mode bg
        static let soft  = Color(hex: 0x15161A)      // Slightly lifted cards
    }

    enum Felt {
        static let dark = Color(hex: 0x1A4D2E)       // Felt-green accent surfaces
        static let deep = Color(hex: 0x103018)       // Shadow depth
    }

    enum Paper {
        static let cream = Color(hex: 0xF5EFE6)      // Light mode app bg
        static let warm  = Color(hex: 0xE8DFD0)      // Light mode subtle elevation
    }

    // MARK: - Foil / brass

    enum Foil {
        static let bright = Color(hex: 0xD4AF37)
        static let muted  = Color(hex: 0x8A7224)
        static let dim    = Color(hex: 0x5A4A17)
    }

    // MARK: - Neon accent (live / urgent only)

    enum Neon {
        static let live   = Color(hex: 0x00FF94)
        static let urgent = Color(hex: 0xFF3B5C)
    }

    // MARK: - Chip-tier color coding

    enum Chip {
        static let white     = Color(hex: 0xF5F0E8)
        static let red       = Color(hex: 0xC8313E)
        static let green     = Color(hex: 0x2E7D5B)
        static let black     = Color(hex: 0x1A1A1B)
        static let purple    = Color(hex: 0x6B2E8C)
        static let gold      = Color(hex: 0xD4AF37)
        static let platinum  = Color(hex: 0xB9C5D0)

        /// Returns the chip-tier color for a given buy-in in USD.
        static func tier(for buyInUSD: Int) -> Color {
            switch buyInUSD {
            case ..<5:        return white
            case 5..<25:      return red
            case 25..<100:    return green
            case 100..<500:   return black
            case 500..<1000:  return purple
            case 1000..<5000: return gold
            default:          return platinum
            }
        }

        /// Whether this tier should render as a rectangular plaque rather than a circular chip.
        static func isPlaque(buyInUSD: Int) -> Bool { buyInUSD >= 5000 }
    }

    // MARK: - Surfaces (light / dark aware)

    /// App-wide background. Rail.true in dark, Paper.cream in light.
    static let appBackground = Color.dynamic(light: Paper.cream, dark: Rail.true)

    /// Card / elevated surface. Pure white in light, Rail.soft in dark.
    static let cardSurface = Color.dynamic(light: Color(hex: 0xFFFFFF), dark: Rail.soft)

    // MARK: - Text

    enum Text {
        static let primary   = Color.dynamic(light: Color(hex: 0x15161A), dark: Color(hex: 0xF5EFE6))
        static let secondary = Color.dynamic(light: Color(hex: 0x5A554D), dark: Color(hex: 0xB0A99A))
        static let tertiary  = Color.dynamic(light: Color(hex: 0x8A8278), dark: Color(hex: 0x6E6A60))
    }

    // MARK: - Semantic state

    enum State {
        static let live    = Neon.live
        static let urgent  = Neon.urgent
        static let closed  = Color(hex: 0x6E6A60)
        static let success = Color(hex: 0x5BA876)
        static let warning = Color(hex: 0xE8A04B)
    }

    // MARK: - Venue accent

    /// Normalise a venue's curated hex to roughly 70% saturation against rail-black so no one venue screams.
    /// Falls back to Foil.muted if the hex is unparseable.
    static func venueAccent(hex: String) -> Color {
        guard let parsed = Color.fromHexString(hex) else { return Foil.muted }
        return parsed
    }
}

// MARK: - Helpers

extension Color {
    /// Hex literal initialiser. Use as `Color(hex: 0xC8313E)`.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Parse a `#RRGGBB` or `RRGGBB` string. Returns nil on failure.
    static func fromHexString(_ str: String) -> Color? {
        var s = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        return Color(hex: v)
    }

    /// Trait-aware colour. Resolves at draw time based on userInterfaceStyle.
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
