import SwiftUI

/// Custom search field replacing .searchable. Magnifying-glass icon + foil-edged frame.
struct AppSearchField: View {
    @Binding var query: String
    var placeholder: String = "Search events"

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.Foil.bright)
            TextField(placeholder, text: $query)
                .font(AppFont.bodyCopy)
                .foregroundStyle(AppColor.Text.primary)
                .submitLabel(.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.Text.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(AppColor.cardSurface, in: Capsule())
        .overlay(Capsule().strokeBorder(AppColor.Foil.muted, lineWidth: 0.5))
    }
}

#Preview("AppSearchField") {
    struct Demo: View {
        @State var a = ""
        @State var b = "bounty"
        var body: some View {
            VStack(spacing: AppSpacing.m) {
                AppSearchField(query: $a)
                AppSearchField(query: $b)
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
