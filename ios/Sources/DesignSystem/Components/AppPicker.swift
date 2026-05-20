import SwiftUI

/// Custom segmented chip group. Replaces Picker(.segmented).
/// Generic over a Hashable selection type.
struct AppPicker<Value: Hashable>: View {
    let options: [(Value, String)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            ForEach(options, id: \.0) { (value, label) in
                Button {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                        selection = value
                    }
                    AppHaptics.filterApplied()
                } label: {
                    Text(label)
                        .font(AppFont.sectionLabel)
                        .tracking(1.0)
                        .foregroundStyle(selection == value ? AppColor.Foil.bright : AppColor.Text.secondary)
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.vertical, AppSpacing.s)
                        .frame(maxWidth: .infinity)
                        .background(
                            selection == value ? AppColor.Foil.bright.opacity(0.12) : Color.clear,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                selection == value ? AppColor.Foil.bright : AppColor.Foil.dim,
                                lineWidth: selection == value ? 0.8 : 0.5
                            )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == value ? [.isSelected, .isButton] : .isButton)
            }
        }
    }
}

#Preview("AppPicker") {
    struct Demo: View {
        enum Status: Hashable { case any, openNow, closingSoon, closed }
        @State var pick: Status = .any
        var body: some View {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text("Late registration").font(AppFont.sectionLabel).tracking(1.4).foregroundStyle(AppColor.Text.secondary)
                AppPicker(options: [
                    (Status.any, "ANY"),
                    (.openNow, "OPEN"),
                    (.closingSoon, "<2H"),
                    (.closed, "CLOSED")
                ], selection: $pick)
            }
            .padding()
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); Demo() }
            .background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); Demo() }
            .background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
