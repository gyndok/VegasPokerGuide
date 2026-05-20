import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var tournaments: [Tournament] = []
    var venues: [Venue] = []
    var lastUpdated: Date? = nil
    var isRefreshing: Bool = false
    var refreshError: String? = nil
    var filters = FilterPredicate()
    var parseWarningCount: Int = 0

    /// Observable mirror of FavoritesStore.allStarred. The store is the disk source of truth;
    /// these mirrors exist so the SwiftUI Observation framework can track mutations and re-render.
    var starredIDs: Set<String> = []
    var notesByID: [String: String] = [:]
    var playedByID: [String: PlayedRecord] = [:]

    private let cache: FeedCache
    private let client: FeedClient
    private let store: FavoritesStore
    private let notifier: NotificationScheduler
    private let defaultLeadMinutes: Int

    init(documentsDirectory: URL,
         client: FeedClient = FeedClient(),
         notifier: NotificationScheduler = NotificationScheduler(),
         defaultLeadMinutes: Int = 30) {
        self.cache = FeedCache(rootDirectory: documentsDirectory.appendingPathComponent("Feed"))
        self.client = client
        self.store = FavoritesStore(rootDirectory: documentsDirectory.appendingPathComponent("Favorites"))
        self.notifier = notifier
        self.defaultLeadMinutes = defaultLeadMinutes
        // Hydrate observable mirrors from disk
        self.starredIDs = store.allStarred
        self.notesByID = Dictionary(uniqueKeysWithValues: store.allStarred.compactMap { id in
            store.note(for: id).map { (id, $0) }
        })
        self.playedByID = Dictionary(uniqueKeysWithValues: store.playedRecords().map { ($0.id, $0) })
    }

    // MARK: - Bootstrap
    func bootstrap() async {
        if let cached = cache.load() {
            apply(cached)
        } else {
            loadBundledSeed()
        }
        await notifier.requestAuthorizationIfNeeded()
        await refresh()
    }

    private func loadBundledSeed() {
        guard
            let tURL = Bundle.main.url(forResource: "tournaments_seed", withExtension: "json"),
            let vURL = Bundle.main.url(forResource: "venues_seed", withExtension: "json"),
            let tData = try? Data(contentsOf: tURL),
            let vData = try? Data(contentsOf: vURL),
            let t = try? FeedDecoder.make().decode(TournamentsFeed.self, from: tData),
            let v = try? FeedDecoder.make().decode(VenuesFeed.self, from: vData)
        else { return }
        tournaments = t.tournaments
        venues = v.venues
        lastUpdated = nil
    }

    private func apply(_ cached: CachedFeed) {
        tournaments = cached.tournaments.tournaments
        venues = cached.venues.venues
        lastUpdated = cached.lastUpdated
    }

    // MARK: - Refresh
    func refresh() async {
        guard let tURL = Config.tournamentsURL, let vURL = Config.venuesURL else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            switch try await client.fetch(tURL, ifNoneMatch: cache.tournamentsETag()) {
            case .notModified: break
            case .updated(let data, let etag):
                cache.saveTournaments(data: data, etag: etag)
                let feed = try FeedDecoder.make().decode(TournamentsFeed.self, from: data)
                tournaments = feed.tournaments
                lastUpdated = Date()
            }
            switch try await client.fetch(vURL, ifNoneMatch: cache.venuesETag()) {
            case .notModified: break
            case .updated(let data, let etag):
                cache.saveVenues(data: data, etag: etag)
                let feed = try FeedDecoder.make().decode(VenuesFeed.self, from: data)
                venues = feed.venues
            }
            // Best-effort: fetch parse_warnings.json count. Failures here don't surface an error.
            if let wURL = Config.warningsURL {
                if case let .updated(data, _) = (try? await client.fetch(wURL, ifNoneMatch: nil)) ?? .notModified {
                    if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let arr = obj["warnings"] as? [Any] {
                        parseWarningCount = arr.count
                    }
                }
            }
            refreshError = nil
            await rescheduleNotifications()
        } catch {
            refreshError = error.localizedDescription
        }
    }

    // MARK: - Views helpers
    func filtered() -> [Tournament] { filters.apply(to: tournaments) }

    func venue(slug: String) -> Venue? { venues.first { $0.slug == slug } }

    // MARK: - Favorites
    func isStarred(_ id: String) -> Bool { starredIDs.contains(id) }
    var starredTournaments: [Tournament] {
        tournaments.filter { starredIDs.contains($0.id) }
    }
    var conflicts: [(String, String)] { ConflictDetector.findConflicts(in: starredTournaments) }
    var starredTotalBuyIn: Int { starredTournaments.compactMap { $0.buyInUSD }.reduce(0, +) }

    func toggleStar(_ t: Tournament) async {
        if starredIDs.contains(t.id) {
            store.unstar(t.id)
            starredIDs.remove(t.id)
            if let nid = store.notificationIdentifier(for: t.id) {
                notifier.cancel(identifier: nid)
                store.removeNotification(tournamentId: t.id)
            }
        } else {
            store.star(t.id)
            starredIDs.insert(t.id)
            if let id = await notifier.schedule(for: t, leadMinutes: defaultLeadMinutes),
               let close = t.lateRegCloseAtPT {
                store.recordNotification(tournamentId: t.id, identifier: id,
                                         leadMinutes: defaultLeadMinutes,
                                         fireDate: close.addingTimeInterval(-Double(defaultLeadMinutes) * 60))
            }
        }
    }

    // MARK: - Notes
    func note(for id: String) -> String? { notesByID[id] }
    func setNote(_ text: String, for id: String) {
        store.setNote(text, for: id)
        if text.isEmpty { notesByID.removeValue(forKey: id) } else { notesByID[id] = text }
    }

    // MARK: - Played
    func playedRecords() -> [PlayedRecord] { Array(playedByID.values) }
    func playedTotals() -> PlayedTotals {
        let records = playedByID.values
        let totalIn = records.reduce(0) { $0 + $1.buyIn }
        let totalCashed = records.reduce(0) { $0 + $1.cashed }
        return PlayedTotals(count: records.count, totalIn: totalIn, totalCashed: totalCashed)
    }
    func recordPlayed(id: String, buyIn: Int, cashed: Int) {
        store.recordPlayed(id: id, buyIn: buyIn, cashed: cashed)
        playedByID[id] = PlayedRecord(id: id, buyIn: buyIn, cashed: cashed, recordedAt: Date())
    }
    func unrecordPlayed(id: String) {
        store.unrecordPlayed(id: id)
        playedByID.removeValue(forKey: id)
    }

    // MARK: - Notification lifecycle on refresh
    /// After a feed refresh, event times may have shifted. Rebuild notifications for every starred event.
    private func rescheduleNotifications() async {
        await notifier.cancelAll(matching: "lr-")
        for t in starredTournaments {
            if let id = await notifier.schedule(for: t, leadMinutes: defaultLeadMinutes),
               let close = t.lateRegCloseAtPT {
                store.recordNotification(tournamentId: t.id, identifier: id,
                                         leadMinutes: defaultLeadMinutes,
                                         fireDate: close.addingTimeInterval(-Double(defaultLeadMinutes) * 60))
            }
        }
    }
}
