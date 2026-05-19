import Foundation

struct PlayedRecord: Codable, Equatable {
    let id: String
    let buyIn: Int
    let cashed: Int
    let recordedAt: Date
}

struct PlayedTotals: Equatable {
    let count: Int
    let totalIn: Int
    let totalCashed: Int
    var net: Int { totalCashed - totalIn }
}

final class FavoritesStore {
    private let dir: URL
    private let favoritesURL: URL
    private let notesURL: URL
    private let playedURL: URL
    private let notificationsURL: URL

    private var favorites: Set<String>
    private var notes: [String: String]
    private var played: [PlayedRecord]
    private var notifications: [String: NotificationMapping]

    struct NotificationMapping: Codable {
        let identifier: String
        let leadMinutes: Int
        let fireDate: Date
    }

    init(rootDirectory: URL) {
        self.dir = rootDirectory
        self.favoritesURL = dir.appendingPathComponent("favorites.json")
        self.notesURL = dir.appendingPathComponent("notes.json")
        self.playedURL = dir.appendingPathComponent("played.json")
        self.notificationsURL = dir.appendingPathComponent("notifications.json")
        self.favorites = Self.load(favoritesURL) ?? []
        self.notes = Self.load(notesURL) ?? [:]
        self.played = Self.load(playedURL) ?? []
        self.notifications = Self.load(notificationsURL) ?? [:]
    }

    // MARK: Favorites
    func isStarred(_ id: String) -> Bool { favorites.contains(id) }
    func star(_ id: String) { favorites.insert(id); persist(favorites, to: favoritesURL) }
    func unstar(_ id: String) { favorites.remove(id); persist(favorites, to: favoritesURL) }
    var allStarred: Set<String> { favorites }

    // MARK: Notes
    func note(for id: String) -> String? { notes[id] }
    func setNote(_ text: String, for id: String) {
        if text.isEmpty { notes.removeValue(forKey: id) } else { notes[id] = text }
        persist(notes, to: notesURL)
    }

    // MARK: Played
    func recordPlayed(id: String, buyIn: Int, cashed: Int, at: Date = Date()) {
        played.removeAll { $0.id == id }
        played.append(PlayedRecord(id: id, buyIn: buyIn, cashed: cashed, recordedAt: at))
        persist(played, to: playedURL)
    }
    func unrecordPlayed(id: String) {
        played.removeAll { $0.id == id }
        persist(played, to: playedURL)
    }
    func playedRecords() -> [PlayedRecord] { played }
    func playedTotals() -> PlayedTotals {
        let totalIn = played.reduce(0) { $0 + $1.buyIn }
        let totalCashed = played.reduce(0) { $0 + $1.cashed }
        return PlayedTotals(count: played.count, totalIn: totalIn, totalCashed: totalCashed)
    }

    // MARK: Notifications
    func recordNotification(tournamentId: String, identifier: String, leadMinutes: Int, fireDate: Date) {
        notifications[tournamentId] = NotificationMapping(identifier: identifier, leadMinutes: leadMinutes, fireDate: fireDate)
        persist(notifications, to: notificationsURL)
    }
    func removeNotification(tournamentId: String) {
        notifications.removeValue(forKey: tournamentId)
        persist(notifications, to: notificationsURL)
    }
    func notificationIdentifier(for tournamentId: String) -> String? {
        notifications[tournamentId]?.identifier
    }

    // MARK: Persistence helpers
    private func persist<T: Encodable>(_ value: T, to url: URL) {
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url, options: .atomic)
        }
    }
    private static func load<T: Decodable>(_ url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
