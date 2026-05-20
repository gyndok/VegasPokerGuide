import SwiftUI

/// Game-category visual treatment. Colors and abbreviations live here;
/// the category itself is the model `GameCategory`.
enum GameCategoryStyle {
    static func abbreviation(_ g: GameCategory) -> String {
        switch g {
        case .nlh:   return "NLH"
        case .plo:   return "PLO"
        case .mixed: return "MIX"
        case .stud:  return "STUD"
        case .draw:  return "DRAW"
        case .other: return "OTHER"
        }
    }

    /// Color treatment for each category. Aligned to the Felt & Foil palette
    /// rather than ad-hoc Color literals.
    static func color(_ g: GameCategory) -> Color {
        switch g {
        case .nlh:   return AppColor.Chip.black         // Default tournament game
        case .plo:   return AppColor.Chip.purple
        case .mixed: return AppColor.Foil.bright        // Mixed games as the "premium" identifier
        case .stud:  return AppColor.Chip.green
        case .draw:  return AppColor.Chip.red
        case .other: return AppColor.Text.tertiary
        }
    }
}
