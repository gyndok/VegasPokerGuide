import SwiftUI

struct RootTabs: View {
    @Environment(AppState.self) private var state
    var body: some View {
        Text("Vegas Poker — \(state.tournaments.count) tournaments")
    }
}
