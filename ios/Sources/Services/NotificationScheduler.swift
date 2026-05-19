import Foundation
import UserNotifications

final class NotificationScheduler {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            // Authorization denied is fine; we silently skip scheduling later.
        }
    }

    /// Schedules a one-shot notification for the given tournament. Returns the request identifier,
    /// or nil if the tournament has no lateRegClose or the fire date is in the past.
    func schedule(for tournament: Tournament, leadMinutes: Int) async -> String? {
        guard let close = tournament.lateRegCloseAtPT else { return nil }
        let fire = close.addingTimeInterval(-Double(leadMinutes) * 60)
        if fire <= Date() { return nil }

        let content = UNMutableNotificationContent()
        content.title = "Late reg closing soon"
        content.body = "\(tournament.eventName) at \(tournament.venue.capitalized) closes in \(leadMinutes) min"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "lr-\(tournament.id)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
            return id
        } catch {
            return nil
        }
    }

    func cancel(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAll(matching prefix: String) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
