import SwiftUI

struct CountdownBadge: View {
    let startAt: Date?
    let lateRegClose: Date?
    @State private var now = Date()
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let state = CountdownState.compute(startAt: startAt, lateRegClose: lateRegClose, now: now)
        Group {
            if state.isVisible {
                Text(state.text)
                    .font(.caption.monospacedDigit())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color(for: state.tier).opacity(0.18))
                    .foregroundStyle(color(for: state.tier))
                    .clipShape(Capsule())
            } else {
                EmptyView()
            }
        }
        .onReceive(tick) { now = $0 }
    }

    private func color(for tier: CountdownState.Tier) -> Color {
        switch tier {
        case .green:  return .green
        case .amber:  return .orange
        case .red:    return .red
        case .closed: return .gray
        case .notRunning, .unknown: return .secondary
        }
    }
}
