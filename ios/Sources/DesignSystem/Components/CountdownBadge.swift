import SwiftUI

/// Live LR countdown badge. Hidden via EmptyView when state.isVisible == false
/// (i.e., event not running or no LR data). Uses semantic state tokens, not system colors.
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
                    .font(AppFont.countdown)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .foregroundStyle(textColor(for: state.tier))
                    .padding(.horizontal, AppSpacing.s)
                    .padding(.vertical, AppSpacing.xs)
                    .background(bgColor(for: state.tier), in: Capsule())
                    .overlay(
                        Capsule().strokeBorder(borderColor(for: state.tier), lineWidth: 0.5)
                    )
            } else {
                EmptyView()
            }
        }
        .onReceive(tick) { newNow in
            withAnimation(.easeInOut(duration: 0.12)) { now = newNow }
        }
        .accessibilityLabel("Late registration \(state.text)")
    }

    private func textColor(for tier: CountdownState.Tier) -> Color {
        switch tier {
        case .green:  return AppColor.State.live
        case .amber:  return AppColor.State.warning
        case .red:    return AppColor.State.urgent
        case .closed: return AppColor.State.closed
        case .notRunning, .unknown: return AppColor.Text.tertiary
        }
    }

    private func bgColor(for tier: CountdownState.Tier) -> Color {
        switch tier {
        case .green:  return AppColor.State.live.opacity(0.12)
        case .amber:  return AppColor.State.warning.opacity(0.15)
        case .red:    return AppColor.State.urgent.opacity(0.18)
        case .closed: return AppColor.State.closed.opacity(0.15)
        case .notRunning, .unknown: return Color.clear
        }
    }

    private func borderColor(for tier: CountdownState.Tier) -> Color {
        switch tier {
        case .green:  return AppColor.Foil.bright.opacity(0.5)
        case .amber:  return AppColor.Foil.bright.opacity(0.6)
        case .red:    return AppColor.State.urgent.opacity(0.5)
        case .closed: return AppColor.Foil.dim
        case .notRunning, .unknown: return Color.clear
        }
    }
}

#Preview("CountdownBadge") {
    let now = Date()
    let running = now.addingTimeInterval(-60)
    func badges() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Text(">2h").font(.caption2); CountdownBadge(startAt: running, lateRegClose: now.addingTimeInterval(3 * 3600)) }
            HStack { Text("amber").font(.caption2); CountdownBadge(startAt: running, lateRegClose: now.addingTimeInterval(45 * 60)) }
            HStack { Text("red").font(.caption2); CountdownBadge(startAt: running, lateRegClose: now.addingTimeInterval(20 * 60)) }
            HStack { Text("closed").font(.caption2); CountdownBadge(startAt: running, lateRegClose: now.addingTimeInterval(-60)) }
            HStack { Text("not running").font(.caption2); CountdownBadge(startAt: now.addingTimeInterval(3 * 3600), lateRegClose: now.addingTimeInterval(6 * 3600)) }
        }
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); badges() }
            .padding().background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); badges() }
            .padding().background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
