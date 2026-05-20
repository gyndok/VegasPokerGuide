import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            ScheduleTab()
                .tabItem { Label("SCHEDULE", systemImage: "list.bullet.rectangle") }
            MyScheduleTab()
                .tabItem { Label("MY TABLE", systemImage: "star.square.fill") }
            PlayedTab()
                .tabItem { Label("PLAYED", systemImage: "checkmark.rectangle.stack") }
        }
        .tint(AppTabBar.selectedColor)
        .background(AppColor.appBackground.ignoresSafeArea())
    }
}
