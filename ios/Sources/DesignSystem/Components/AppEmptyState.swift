import SwiftUI

/// Custom empty-state view with display-font title, body copy, and a bespoke SwiftUI Path illustration.
/// Two illustration variants for the two empty contexts in the app (My Schedule, Played).
struct AppEmptyState: View {
    let illustration: Illustration
    let title: String
    let message: String

    enum Illustration { case fadedChips, foldedCard }

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            illustrationView
                .frame(width: 110, height: 110)
            VStack(spacing: AppSpacing.s) {
                Text(title)
                    .font(AppFont.sheetTitle)
                    .foregroundStyle(AppColor.Text.primary)
                Text(message)
                    .font(AppFont.bodyCopy)
                    .foregroundStyle(AppColor.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }

    @ViewBuilder
    private var illustrationView: some View {
        switch illustration {
        case .fadedChips: FadedChipsIllustration()
        case .foldedCard: FoldedCardIllustration()
        }
    }
}

/// A stack of three chips with a star floating above. Used for the empty My Schedule state.
private struct FadedChipsIllustration: View {
    var body: some View {
        ZStack {
            // Three chips, slightly offset, each a different denomination color (black, green, red)
            ZStack {
                ChipShape().fill(AppColor.Chip.red.opacity(0.45))
                ChipShape().stroke(AppColor.Foil.muted, lineWidth: 0.8)
            }
            .frame(width: 70, height: 70)
            .offset(y: 22)
            ZStack {
                ChipShape().fill(AppColor.Chip.green.opacity(0.55))
                ChipShape().stroke(AppColor.Foil.muted, lineWidth: 0.8)
            }
            .frame(width: 70, height: 70)
            .offset(y: 8)
            ZStack {
                ChipShape().fill(AppColor.Chip.black.opacity(0.75))
                ChipShape().stroke(AppColor.Foil.bright, lineWidth: 0.8)
            }
            .frame(width: 70, height: 70)
            .offset(y: -6)
            // Star above
            StarShape()
                .fill(AppColor.Foil.bright)
                .frame(width: 22, height: 22)
                .offset(y: -42)
        }
    }
}

/// A folded playing card with a question mark cut-out. Used for the empty Played state.
private struct FoldedCardIllustration: View {
    var body: some View {
        ZStack {
            ZStack {
                CardShape().fill(AppColor.cardSurface)
                CardShape().stroke(AppColor.Foil.bright, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            .frame(width: 70, height: 100)
            .rotationEffect(.degrees(-8))
            Text("?")
                .font(.custom("Fraunces", size: 44).weight(.semibold))
                .foregroundStyle(AppColor.Foil.bright)
                .rotationEffect(.degrees(-8))
        }
    }
}

/// A simple poker-chip silhouette: circle with a hatched ring.
private struct ChipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: rect)
        // Inner hatched ring at 70% radius
        let inset = rect.width * 0.18
        let inner = rect.insetBy(dx: inset, dy: inset)
        p.addEllipse(in: inner)
        return p
    }
}

/// A rounded-rect playing card silhouette.
private struct CardShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: 8)
    }
}

/// A 5-point star.
private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.4
        var p = Path()
        for i in 0..<10 {
            let r = (i % 2 == 0) ? outerR : innerR
            let angle = Double(i) * .pi / 5 - .pi / 2
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

#Preview("AppEmptyState") {
    VStack(spacing: 0) {
        AppEmptyState(illustration: .fadedChips,
                      title: "No starred events",
                      message: "Tap the star on any event in the Schedule tab to plan it.")
        .background(AppColor.appBackground)
        Divider()
        AppEmptyState(illustration: .foldedCard,
                      title: "Nothing played yet",
                      message: "Mark a tournament as Played from its detail screen.")
        .background(AppColor.appBackground)
    }
    .environment(\.colorScheme, .dark)
}

#Preview("AppEmptyState Light") {
    VStack(spacing: 0) {
        AppEmptyState(illustration: .fadedChips,
                      title: "No starred events",
                      message: "Tap the star on any event in the Schedule tab to plan it.")
        .background(AppColor.appBackground)
        Divider()
        AppEmptyState(illustration: .foldedCard,
                      title: "Nothing played yet",
                      message: "Mark a tournament as Played from its detail screen.")
        .background(AppColor.appBackground)
    }
    .environment(\.colorScheme, .light)
}
