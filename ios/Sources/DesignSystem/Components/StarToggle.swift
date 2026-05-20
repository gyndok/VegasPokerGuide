import SwiftUI

/// Replaces the default Image(systemName: "star.fill") with a chip-plaque-inspired toggle.
/// When on: foil-bright filled plaque with a star inset.
/// When off: foil-dim outline only.
/// The action is provided as a closure (binding-style usage is awkward with async toggles).
struct StarToggle: View {
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.chipPlaque)
                    .fill(isOn ? AppColor.Foil.bright.opacity(0.95) : Color.clear)
                    .frame(width: 28, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.chipPlaque)
                            .strokeBorder(isOn ? AppColor.Foil.bright : AppColor.Foil.dim, lineWidth: 0.8)
                    )
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isOn ? AppColor.Rail.true : AppColor.Foil.dim)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "Starred" : "Not starred")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("StarToggle") {
    struct Demo: View {
        @State var a = false
        @State var b = true
        var body: some View {
            HStack(spacing: 16) {
                StarToggle(isOn: a) { a.toggle() }
                StarToggle(isOn: b) { b.toggle() }
            }
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); Demo() }
            .padding().background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); Demo() }
            .padding().background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
