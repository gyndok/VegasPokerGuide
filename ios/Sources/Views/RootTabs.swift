import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            ScheduleTab()
                .tabItem { Label("Schedule", systemImage: "list.bullet") }
            MyScheduleTab()
                .tabItem { Label("My Schedule", systemImage: "star.fill") }
            PlayedTab()
                .tabItem { Label("Played", systemImage: "checkmark.seal") }
        }
    }
}
