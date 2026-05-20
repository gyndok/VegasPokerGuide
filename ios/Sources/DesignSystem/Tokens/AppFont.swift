import SwiftUI

/// Typography presets for the Felt & Foil design system.
/// All presets are declared `relativeTo:` a system style so Dynamic Type works.
enum AppFont {

    // MARK: - Faces

    private enum Face {
        static let fraunces = "Fraunces"               // PostScript family name
        static let inter = "InterVariable"             // PostScript name: InterVariable (family = "Inter Variable")
        static let interItalic = "InterVariableItalic" // PostScript name: InterVariableItalic
        static let mono = "JetBrainsMono-Regular"      // Variable JetBrains Mono PostScript name
    }

    // MARK: - Display (Fraunces)

    static let tabTitle = Font.custom(Face.fraunces, size: 11, relativeTo: .caption).weight(.semibold)
    static let largeTitle = Font.custom(Face.fraunces, size: 28, relativeTo: .title).weight(.semibold)
    static let sheetTitle = Font.custom(Face.fraunces, size: 22, relativeTo: .title2).weight(.semibold)
    static let eventName = Font.custom(Face.fraunces, size: 17, relativeTo: .body).weight(.medium)
    static let dayHeader = Font.custom(Face.fraunces, size: 16, relativeTo: .headline).weight(.semibold)

    // MARK: - Body (Inter)

    static let sectionLabel = Font.custom(Face.inter, size: 10, relativeTo: .caption2).weight(.semibold)
    static let bodyCopy = Font.custom(Face.inter, size: 15, relativeTo: .body)
    static let meta = Font.custom(Face.inter, size: 12, relativeTo: .caption)
    static let notesBody = Font.custom(Face.interItalic, size: 15, relativeTo: .body)

    // MARK: - Mono (JetBrains Mono)
    // All mono presets force tabular figures via `.featureSettings` when applied with `.monospacedDigit()` semantics.
    // The variable JetBrains Mono ships with tnum on by default for the digit positions we care about.

    static let buyIn = Font.custom(Face.mono, size: 14, relativeTo: .subheadline).weight(.medium)
    static let buyInLarge = Font.custom(Face.mono, size: 22, relativeTo: .title2).weight(.semibold)
    static let countdown = Font.custom(Face.mono, size: 13, relativeTo: .caption).weight(.medium)
    static let countdownLarge = Font.custom(Face.mono, size: 36, relativeTo: .largeTitle).weight(.semibold)
    static let stat = Font.custom(Face.mono, size: 22, relativeTo: .title2).weight(.semibold)
    static let timestamp = Font.custom(Face.mono, size: 12, relativeTo: .caption)
}
