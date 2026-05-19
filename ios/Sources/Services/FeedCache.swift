import Foundation

struct CachedFeed {
    let tournaments: TournamentsFeed
    let venues: VenuesFeed
    let lastUpdated: Date
}

final class FeedCache {
    private let dir: URL
    private var tournamentsURL: URL { dir.appendingPathComponent("tournaments_cache.json") }
    private var venuesURL: URL { dir.appendingPathComponent("venues_cache.json") }
    private var tournamentsETagURL: URL { dir.appendingPathComponent("tournaments.etag") }
    private var venuesETagURL: URL { dir.appendingPathComponent("venues.etag") }

    init(rootDirectory: URL) {
        self.dir = rootDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    func load() -> CachedFeed? {
        guard let tData = try? Data(contentsOf: tournamentsURL),
              let vData = try? Data(contentsOf: venuesURL),
              let t = try? FeedDecoder.make().decode(TournamentsFeed.self, from: tData),
              let v = try? FeedDecoder.make().decode(VenuesFeed.self, from: vData) else {
            return nil
        }
        let attrs = try? FileManager.default.attributesOfItem(atPath: tournamentsURL.path)
        let date = (attrs?[.modificationDate] as? Date) ?? Date()
        return CachedFeed(tournaments: t, venues: v, lastUpdated: date)
    }

    func saveTournaments(data: Data, etag: String?) {
        try? data.write(to: tournamentsURL, options: .atomic)
        if let etag { try? etag.write(to: tournamentsETagURL, atomically: true, encoding: .utf8) }
    }
    func saveVenues(data: Data, etag: String?) {
        try? data.write(to: venuesURL, options: .atomic)
        if let etag { try? etag.write(to: venuesETagURL, atomically: true, encoding: .utf8) }
    }
    func tournamentsETag() -> String? { try? String(contentsOf: tournamentsETagURL, encoding: .utf8) }
    func venuesETag() -> String? { try? String(contentsOf: venuesETagURL, encoding: .utf8) }
}
