import SwiftUI

/// Replaces stock Toggle with a chip-pip indicator. Fills with `accent` when on; foil-dim outline when off.
struct AppToggle: View {
    let title: String
    @Binding var isOn: Bool
    var accent: Color = AppColor.Foil.bright

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                isOn.toggle()
            }
            AppHaptics.filterApplied()
        } label: {
            HStack(spacing: AppSpacing.m) {
                Text(title)
                    .font(AppFont.bodyCopy)
                    .foregroundStyle(AppColor.Text.primary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: AppSpacing.s)
                pip
            }
            .padding(.vertical, AppSpacing.s)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
    }

    private var pip: some View {
        ZStack {
            Circle()
                .fill(isOn ? accent.opacity(0.95) : Color.clear)
            Circle()
                .strokeBorder(isOn ? accent : AppColor.Foil.dim, lineWidth: 1)
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppColor.Rail.true)
            }
        }
        .frame(width: 22, height: 22)
    }
}

#Preview("AppToggle") {
    struct Demo: View {
        @State var a = false
        @State var b = true
        @State var c = false
        var body: some View {
            VStack(spacing: 0) {
                AppToggle(title: "Venetian", isOn: $a, accent: Color(red: 0.55, green: 0, blue: 0))
                AppToggle(title: "Wynn", isOn: $b, accent: Color(red: 0.72, green: 0.53, blue: 0.04))
                AppToggle(title: "Show Day 2 / final tables — a long label that wraps if narrow", isOn: $c)
            }
            .padding(.horizontal, AppSpacing.l)
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); Demo() }
            .padding(.vertical).background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); Demo() }
            .padding(.vertical).background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
