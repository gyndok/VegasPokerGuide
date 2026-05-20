import SwiftUI

/// Game-category pill (NLH / PLO / MIX / STUD / DRAW / OTHER) with a restrained color treatment.
/// Uses GameCategoryStyle for abbreviation + color.
struct GameChip: View {
    let category: GameCategory

    var body: some View {
        let color = GameCategoryStyle.color(category)
        Text(GameCategoryStyle.abbreviation(category))
            .font(AppFont.sectionLabel)
            .tracking(0.8)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: AppRadius.badge))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.badge)
                    .strokeBorder(color.opacity(0.4), lineWidth: 0.5)
            )
    }
}

#Preview("GameChip") {
    func grid() -> some View {
        let all: [GameCategory] = [.nlh, .plo, .mixed, .stud, .draw, .other]
        return HStack(spacing: 6) {
            ForEach(all, id: \.self) { GameChip(category: $0) }
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); grid() }
            .padding().background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); grid() }
            .padding().background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
