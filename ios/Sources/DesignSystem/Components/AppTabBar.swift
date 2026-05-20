import SwiftUI
import UIKit

/// Restyled TabView appearance. Per the "graceful degradation" strategy, we keep
/// SwiftUI's TabView (for iOS 26 floating tab bar, safe-areas, haptics, iPad multitasking)
/// and customize UITabBarAppearance plus apply our tint.
///
/// Call `AppTabBar.configure()` once at app startup. Apply `.tint(AppTabBar.selectedColor)`
/// to the TabView. The unselected color is derived automatically as a dimmer foil.
enum AppTabBar {

    static let selectedColor = AppColor.Foil.bright

    /// One-time setup. Idempotent. Call from VegasPokerGuideApp init or .onAppear.
    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(AppColor.Rail.soft) : UIColor(AppColor.Paper.warm)
        }
        // Subtle foil hairline on the top edge of the tab bar
        appearance.shadowColor = UIColor(AppColor.Foil.bright.opacity(0.6))

        // Title attributes — display font for tab labels
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Fraunces-SemiBold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor(AppColor.Foil.dim),
            .kern: 1.4
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Fraunces-SemiBold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor(AppColor.Foil.bright),
            .kern: 1.4
        ]

        for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            item.normal.titleTextAttributes = normalAttrs
            item.selected.titleTextAttributes = selectedAttrs
            item.normal.iconColor = UIColor(AppColor.Foil.dim)
            item.selected.iconColor = UIColor(AppColor.Foil.bright)
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview("AppTabBar (TabView host)") {
    // Calling configure here means the preview reflects the runtime look.
    let _ = AppTabBar.configure()
    return TabView {
        Color.clear.tabItem { Label("SCHEDULE", systemImage: "list.bullet") }
        Color.clear.tabItem { Label("MY SCHEDULE", systemImage: "star.fill") }
        Color.clear.tabItem { Label("PLAYED", systemImage: "checkmark.seal") }
    }
    .tint(AppTabBar.selectedColor)
    .background(AppColor.appBackground)
    .environment(\.colorScheme, .dark)
}
