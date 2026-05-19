import Foundation
import EventKit

final class CalendarExporter {
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do { return try await store.requestWriteOnlyAccessToEvents() } catch { return false }
        } else {
            return await withCheckedContinuation { cont in
                store.requestAccess(to: .event) { granted, _ in cont.resume(returning: granted) }
            }
        }
    }

    func add(tournament: Tournament, venue: Venue?) async throws {
        guard await requestAccess() else {
            throw NSError(domain: "VegasPokerGuide", code: 1, userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"])
        }
        let event = EKEvent(eventStore: store)
        event.title = "\(tournament.eventName) — \(venue?.displayName ?? tournament.venue.capitalized)"
        event.startDate = tournament.startAtPT ?? tournament.datePT
        event.endDate = tournament.lateRegCloseAtPT ?? event.startDate.addingTimeInterval(4 * 3600)
        if let buyIn = tournament.buyInUSD {
            event.notes = "Buy-in: $\(buyIn). Re-entry: \(ReEntryFormatter.format(tournament.reEntry))."
        }
        event.location = venue?.address
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }
}
