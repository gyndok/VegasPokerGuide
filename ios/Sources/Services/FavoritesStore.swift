import Foundation

struct PlayedRecord: Codable, Equatable {
    let id: String
    let buyIn: Int
    let cashed: Int
    let recordedAt: Date
    let entries: Int
    let hoursPlayed: Double?

    // Custom decoder for back-compat: existing JSON without `entries`/`hoursPlayed` still decodes.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        buyIn = try c.decode(Int.self, forKey: .buyIn)
        cashed = try c.decode(Int.self, forKey: .cashed)
        recordedAt = try c.decode(Date.self, forKey: .recordedAt)
        entries = (try? c.decodeIfPresent(Int.self, forKey: .entries)) ?? 1
        hoursPlayed = try? c.decodeIfPresent(Double.self, forKey: .hoursPlayed)
    }

    init(id: String, buyIn: Int, cashed: Int, recordedAt: Date, entries: Int = 1, hoursPlayed: Double? = nil) {
        self.id = id
        self.buyIn = buyIn
        self.cashed = cashed
        self.recordedAt = recordedAt
        self.entries = entries
        self.hoursPlayed = hoursPlayed
    }
}

struct PlayedTotals: Equatable {
    let count: Int
    let totalIn: Int
    let totalCashed: Int
    let totalHours: Double
    var net: Int { totalCashed - totalIn }
    var roi: Double? {
        guard totalIn > 0 else { return nil }
        return Double(net) / Double(totalIn)
    }
    var hourlyRate: Double? {
        guard totalHours > 0 else { return nil }
        return Double(net) / totalHours
    }
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
    func recordPlayed(id: String, buyIn: Int, cashed: Int, entries: Int = 1, hoursPlayed: Double? = nil, at: Date = Date()) {
        played.removeAll { $0.id == id }
        played.append(PlayedRecord(id: id, buyIn: buyIn, cashed: cashed, recordedAt: at, entries: entries, hoursPlayed: hoursPlayed))
        persist(played, to: playedURL)
    }
    func unrecordPlayed(id: String) {
        played.removeAll { $0.id == id }
        persist(played, to: playedURL)
    }
    func playedRecords() -> [PlayedRecord] { played }
    func playedTotals() -> PlayedTotals {
        let totalIn = played.reduce(0) { $0 + $1.buyIn * $1.entries }
        let totalCashed = played.reduce(0) { $0 + $1.cashed }
        let totalHours = played.reduce(0.0) { $0 + ($1.hoursPlayed ?? 0.0) }
        return PlayedTotals(count: played.count, totalIn: totalIn, totalCashed: totalCashed, totalHours: totalHours)
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
