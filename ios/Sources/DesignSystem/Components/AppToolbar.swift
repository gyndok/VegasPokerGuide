import SwiftUI

/// Custom toolbar button helpers for the Schedule tab.
/// Use INSIDE a `.toolbar { ... }` block. These are SwiftUI Views, not ToolbarContent,
/// so wrap them in `ToolbarItem(placement: ...) { AppToolbar.gearButton(action: ...) }`.
enum AppToolbar {

    /// Gear icon for the Settings entry point.
    static func gearButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "gearshape")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColor.Foil.bright)
                .frame(width: 30, height: 30)
                .background(AppColor.Foil.bright.opacity(0.08), in: Circle())
                .overlay(Circle().strokeBorder(AppColor.Foil.bright.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Settings")
    }

    /// Filters button with a custom badge count (replaces the default red-dot Label badge).
    static func filtersButton(activeCount: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 13, weight: .medium))
                Text("Filters")
                    .font(AppFont.sectionLabel)
                    .tracking(1.0)
                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.custom("JetBrainsMono-Regular", size: 11).weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.Rail.true)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(AppColor.Foil.bright, in: RoundedRectangle(cornerRadius: 3))
                }
            }
            .foregroundStyle(AppColor.Foil.bright)
            .padding(.horizontal, AppSpacing.m)
            .padding(.vertical, 6)
            .background(AppColor.Foil.bright.opacity(0.08), in: Capsule())
            .overlay(Capsule().strokeBorder(AppColor.Foil.bright.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(activeCount > 0 ? "Filters, \(activeCount) active" : "Filters")
    }
}

#Preview("AppToolbar") {
    func bar() -> some View {
        HStack {
            AppToolbar.gearButton(action: { })
            Spacer()
            AppToolbar.filtersButton(activeCount: 0, action: { })
            AppToolbar.filtersButton(activeCount: 3, action: { })
        }
        .padding()
    }
    return VStack(spacing: 0) {
        bar()
            .background(AppColor.appBackground)
            .environment(\.colorScheme, .light)
        bar()
            .background(AppColor.appBackground)
            .environment(\.colorScheme, .dark)
    }
}
