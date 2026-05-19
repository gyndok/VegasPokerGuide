import SwiftUI

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
    static func color(_ g: GameCategory) -> Color {
        switch g {
        case .nlh:   return Color(red: 0.18, green: 0.46, blue: 0.85)
        case .plo:   return Color(red: 0.95, green: 0.55, blue: 0.18)
        case .mixed: return Color(red: 0.60, green: 0.30, blue: 0.78)
        case .stud:  return Color(red: 0.22, green: 0.66, blue: 0.40)
        case .draw:  return Color(red: 0.16, green: 0.60, blue: 0.70)
        case .other: return .gray
        }
    }
}
