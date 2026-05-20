import SwiftUI

/// Primary action button. Chip-shaped silhouette, foil-bright filled.
/// Three variants for different action weights.
struct AppButton: View {
    enum Style { case primary, secondary, destructive }

    let title: String
    let systemImage: String?
    let style: Style
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(AppFont.sectionLabel)
                    .tracking(1.2)
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, AppSpacing.m)
            .frame(maxWidth: .infinity)
            .background(background, in: RoundedRectangle(cornerRadius: AppRadius.chip))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.chip)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var foreground: Color {
        switch style {
        case .primary:     return AppColor.Rail.true
        case .secondary:   return AppColor.Foil.bright
        case .destructive: return AppColor.Chip.red
        }
    }

    private var background: Color {
        switch style {
        case .primary:     return AppColor.Foil.bright
        case .secondary:   return AppColor.Foil.bright.opacity(0.08)
        case .destructive: return AppColor.Chip.red.opacity(0.10)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:     return AppColor.Foil.bright
        case .secondary:   return AppColor.Foil.bright.opacity(0.6)
        case .destructive: return AppColor.Chip.red.opacity(0.7)
        }
    }

    private var borderWidth: CGFloat { style == .primary ? 0 : 0.8 }
}

#Preview("AppButton") {
    func column() -> some View {
        VStack(spacing: AppSpacing.m) {
            AppButton("Refresh now", systemImage: "arrow.clockwise") { }
            AppButton("Open Structure Sheet", systemImage: "doc.text", style: .secondary) { }
            AppButton("Reset filters", style: .destructive) { }
            AppButton("Very long primary button label that wraps perhaps") { }
        }
        .padding()
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); column() }
            .background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); column() }
            .background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
