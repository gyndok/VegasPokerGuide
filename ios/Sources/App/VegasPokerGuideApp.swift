import SwiftUI

@main
struct VegasPokerGuideApp: App {
    @State private var state: AppState

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        _state = State(initialValue: AppState(documentsDirectory: docs))
    }

    var body: some Scene {
        WindowGroup {
            RootTabs()
                .environment(state)
                .task { await state.bootstrap() }
        }
    }
}
