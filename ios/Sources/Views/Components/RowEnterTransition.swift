import SwiftUI

/// Per-row enter transition. Index drives a small delay (max 8 rows of stagger).
/// `appeared` is owned by the parent so re-renders after the initial appearance snap immediately.
struct RowEnterTransition: ViewModifier {
    let index: Int
    @Binding var appeared: Bool

    private var delay: Double {
        // Cap stagger to first 8 visible rows so deep scrolls don't accumulate.
        let capped = min(index, 8)
        return Double(capped) * 0.03
    }

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(.easeOut(duration: 0.18).delay(delay), value: appeared)
    }
}
