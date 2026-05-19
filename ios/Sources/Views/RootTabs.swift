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

// Placeholders — replaced by real views in later tasks.
struct MyScheduleTab: View { var body: some View { Text("My Schedule (stub)") } }
struct PlayedTab: View { var body: some View { Text("Played (stub)") } }
