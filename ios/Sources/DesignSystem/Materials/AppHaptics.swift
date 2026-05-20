import UIKit

/// Named haptic events for the Felt & Foil design system.
/// Each is a single function call so view code stays readable: `AppHaptics.starToggled()`.
enum AppHaptics {

    static func filterApplied() { impact(.light) }
    static func starToggled()   { impact(.medium) }
    static func eventOpened()   { impact(.light) }
    static func tabSwitched()   { impact(.light) }
    static func lrClosed()      { impact(.heavy) }

    static func refreshComplete() { notify(.success) }
    static func refreshFailed()   { notify(.error) }

    // MARK: - Private

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.prepare()
        gen.impactOccurred()
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(type)
    }
}
