import SwiftUI

/// Background treatment for List rows: flat felt-toned fill, foil hairline separator at the bottom edge.
/// Use as the `.listRowBackground(...)` value or wrap row content directly.
struct AppRowBackground: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.cardSurface
            AppHairline.divider(opacity: 0.35)
        }
    }
}

/// Modifier that wraps a row in the AppRowBackground treatment and hides the system separator.
extension View {
    func appRowStyle() -> some View {
        self
            .listRowBackground(AppRowBackground())
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.l, bottom: AppSpacing.xs, trailing: AppSpacing.l))
    }
}

#Preview("AppRowBackground") {
    func rows() -> some View {
        List {
            ForEach(0..<6) { i in
                HStack {
                    Text("Row \(i)").font(AppFont.eventName).foregroundStyle(AppColor.Text.primary)
                    Spacer()
                    Text("$\(600 + i * 100)").font(AppFont.buyIn).foregroundStyle(AppColor.Text.primary)
                }
                .appRowStyle()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    return TabView {
        rows()
            .background(AppColor.Paper.cream).environment(\.colorScheme, .light)
            .tabItem { Text("Light") }
        rows()
            .background(AppColor.Rail.true).environment(\.colorScheme, .dark)
            .tabItem { Text("Dark") }
    }
}
