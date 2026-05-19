import Foundation

enum Config {
    /// Set this to your published feed root, e.g. "https://gyndok.github.io/VegasPokerGuide".
    /// Leave empty during local development — the app will load from the bundled seed.
    static let feedBaseURL: String = ""

    private static func url(forFile filename: String) -> URL? {
        guard !feedBaseURL.isEmpty, let base = URL(string: feedBaseURL) else { return nil }
        return base.appendingPathComponent(filename)
    }
    static var tournamentsURL: URL? { url(forFile: "tournaments.json") }
    static var venuesURL: URL? { url(forFile: "venues.json") }
    static var warningsURL: URL? { url(forFile: "parse_warnings.json") }
}
