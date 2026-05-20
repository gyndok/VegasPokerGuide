import SwiftUI

/// Restyled top bar for modal sheets. Display-font title, foil hairline beneath, custom Done button.
/// Use INSIDE the sheet's content, not as a navigation title.
///
/// Example:
///   NavigationStack {
///     VStack(spacing: 0) {
///       AppSheetHeader(title: "Filters", onDismiss: { dismiss() })
///       ScrollView { ... }
///     }
///     .navigationBarHidden(true)
///   }
struct AppSheetHeader: View {
    let title: String
    var trailing: (() -> AnyView)? = nil
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: AppSpacing.m) {
                Text(title)
                    .font(AppFont.sheetTitle)
                    .foregroundStyle(AppColor.Text.primary)
                Spacer()
                if let trailing { trailing() }
                Button(action: onDismiss) {
                    Text("Done")
                        .font(AppFont.sectionLabel)
                        .tracking(1.2)
                        .foregroundStyle(AppColor.Foil.bright)
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.vertical, AppSpacing.s)
                        .background(AppColor.Foil.bright.opacity(0.12), in: Capsule())
                        .overlay(Capsule().strokeBorder(AppColor.Foil.bright.opacity(0.5), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, AppSpacing.m)
            .frame(maxWidth: .infinity)
            .background(
                ZStack { AppTexture.feltSurface() }
                    .clipped()
            )
            AppHairline.divider(opacity: 0.9)
        }
    }
}

#Preview("AppSheetHeader") {
    VStack(spacing: 0) {
        AppSheetHeader(title: "Filters", onDismiss: { })
        Spacer()
    }
    .frame(height: 200)
    .background(AppColor.appBackground)
    .environment(\.colorScheme, .dark)
}

#Preview("AppSheetHeader Light") {
    VStack(spacing: 0) {
        AppSheetHeader(title: "Settings", onDismiss: { })
        Spacer()
    }
    .frame(height: 200)
    .background(AppColor.appBackground)
    .environment(\.colorScheme, .light)
}
