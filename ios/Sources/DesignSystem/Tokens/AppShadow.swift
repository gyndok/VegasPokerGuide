import SwiftUI

/// Subtle elevation shadows. Used sparingly — most depth is conveyed by foil hairlines, not shadow.
struct AppShadow: ViewModifier {
    let depth: Depth

    enum Depth { case soft, medium, prominent }

    private var color: Color {
        Color.black.opacity(depth == .soft ? 0.20 : depth == .medium ? 0.30 : 0.40)
    }
    private var radius: CGFloat { depth == .soft ? 4 : depth == .medium ? 8 : 16 }
    private var y: CGFloat { depth == .soft ? 1 : depth == .medium ? 3 : 6 }

    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: 0, y: y)
    }
}

extension View {
    func appShadow(_ depth: AppShadow.Depth = .soft) -> some View {
        modifier(AppShadow(depth: depth))
    }
}
