import SwiftUI

/// Buy-in figure rendered in tabular-mono with the standard chip-tier color dot beside it.
/// At $5K+ the dot becomes a foil-framed rectangular plaque to mark the jump.
struct BuyInBadge: View {
    let amountUSD: Int?

    private var displayAmount: String {
        guard let n = amountUSD else { return "—" }
        return "$\(n.formatted(.number.grouping(.automatic)))"
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if let amt = amountUSD {
                if AppColor.Chip.isPlaque(buyInUSD: amt) {
                    // Rectangular plaque for $5K+
                    Rectangle()
                        .fill(AppColor.Chip.tier(for: amt))
                        .frame(width: 10, height: 8)
                        .clipShape(RoundedRectangle(cornerRadius: 1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                .strokeBorder(AppColor.Foil.bright, lineWidth: 0.5)
                        )
                } else {
                    // Circular chip
                    Circle()
                        .fill(AppColor.Chip.tier(for: amt))
                        .frame(width: 8, height: 8)
                        .overlay(Circle().strokeBorder(AppColor.Foil.muted, lineWidth: 0.5))
                }
            }
            Text(displayAmount)
                .font(AppFont.buyIn)
                .foregroundStyle(AppColor.Text.primary)
        }
    }
}

#Preview("BuyInBadge") {
    let amounts: [Int?] = [200, 600, 1100, 5000, 10000, nil]
    func col() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(amounts.enumerated()), id: \.offset) { _, a in
                BuyInBadge(amountUSD: a)
            }
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); col() }
            .padding().background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); col() }
            .padding().background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
