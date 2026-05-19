import Foundation

struct CountdownState: Equatable {
    enum Tier: Equatable { case green, amber, red, closed, unknown }
    let tier: Tier
    let text: String
    let isClosed: Bool

    static func compute(lateRegClose: Date?, now: Date = Date()) -> CountdownState {
        guard let close = lateRegClose else {
            return CountdownState(tier: .unknown, text: "—", isClosed: false)
        }
        let remaining = close.timeIntervalSince(now)
        if remaining <= 0 {
            return CountdownState(tier: .closed, text: "Closed", isClosed: true)
        }
        let tier: Tier
        switch remaining {
        case ..<(30 * 60):       tier = .red
        case ..<(2 * 3600):      tier = .amber
        default:                 tier = .green
        }
        return CountdownState(tier: tier, text: format(seconds: Int(remaining)), isClosed: false)
    }

    private static func format(seconds total: Int) -> String {
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return "\(h)h \(m)m \(s)s" }
        return "\(m)m \(s)s"
    }
}
