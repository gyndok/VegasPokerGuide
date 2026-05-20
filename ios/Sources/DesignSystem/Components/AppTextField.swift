import SwiftUI

/// Number-input text field with foil-edged frame and tabular-mono digits.
/// `value` is an optional Int so the field can be empty (means "no limit").
struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var value: Int?

    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.bodyCopy)
                .foregroundStyle(AppColor.Text.secondary)
            Spacer()
            TextField(placeholder, value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(AppFont.buyIn)
                .monospacedDigit()
                .foregroundStyle(AppColor.Text.primary)
                .frame(maxWidth: 120)
                .padding(.horizontal, AppSpacing.s)
                .padding(.vertical, 6)
                .background(AppColor.cardSurface, in: RoundedRectangle(cornerRadius: AppRadius.badge))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.badge)
                        .strokeBorder(AppColor.Foil.muted, lineWidth: 0.5)
                )
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview("AppTextField") {
    struct Demo: View {
        @State var min: Int? = nil
        @State var max: Int? = 1100
        var body: some View {
            VStack(spacing: 0) {
                AppTextField(label: "Min buy-in", placeholder: "0", value: $min)
                AppTextField(label: "Max buy-in", placeholder: "∞", value: $max)
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
