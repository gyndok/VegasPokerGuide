import SwiftUI

struct GameCategoryChip: View {
    let category: GameCategory
    var body: some View {
        Text(GameCategoryStyle.abbreviation(category))
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(GameCategoryStyle.color(category).opacity(0.18))
            .foregroundStyle(GameCategoryStyle.color(category))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
