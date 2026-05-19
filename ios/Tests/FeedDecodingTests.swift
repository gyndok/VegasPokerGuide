import XCTest
@testable import VegasPokerGuide

final class FeedDecodingTests: XCTestCase {
    private func data(for fixture: String) throws -> Data {
        let url = Bundle(for: type(of: self)).url(forResource: fixture, withExtension: "json")!
        return try Data(contentsOf: url)
    }

    func testDecodesTournaments() throws {
        let feed = try FeedDecoder.make().decode(TournamentsFeed.self, from: try data(for: "tournaments_sample"))
        XCTAssertEqual(feed.tournaments.count, 2)
        let t = feed.tournaments[0]
        XCTAssertEqual(t.id, "venetian-2026-05-19-nlh-1b")
        XCTAssertEqual(t.venue, "venetian")
        XCTAssertEqual(t.eventName, "NLH 1B")
        XCTAssertEqual(t.buyInUSD, 600)
        XCTAssertEqual(t.guaranteeUSD, 150000)
        XCTAssertEqual(t.reEntry.type, .unlimited)
        XCTAssertEqual(t.gameCategory, .nlh)
        XCTAssertFalse(t.isDay2)
        XCTAssertNotNil(t.startAtPT)
        XCTAssertNotNil(t.lateRegCloseAtPT)
    }

    func testToleratesNullTimes() throws {
        let feed = try FeedDecoder.make().decode(TournamentsFeed.self, from: try data(for: "tournaments_sample"))
        let day2 = feed.tournaments[1]
        XCTAssertNil(day2.startAtPT)
        XCTAssertNil(day2.lateRegCloseAtPT)
        XCTAssertNil(day2.buyInUSD)
        XCTAssertTrue(day2.isDay2)
    }

    func testDecodesVenues() throws {
        let feed = try FeedDecoder.make().decode(VenuesFeed.self, from: try data(for: "venues_sample"))
        XCTAssertEqual(feed.venues.count, 1)
        XCTAssertEqual(feed.venues[0].slug, "venetian")
        XCTAssertEqual(feed.venues[0].colorHex, "#8B0000")
    }

    func testStartTimeIsCorrectInstant() throws {
        let feed = try FeedDecoder.make().decode(TournamentsFeed.self, from: try data(for: "tournaments_sample"))
        // 2026-05-19T11:10:00-07:00 == 2026-05-19T18:10:00Z
        let comp = Calendar(identifier: .gregorian)
        var cal = comp
        cal.timeZone = TimeZone(identifier: "UTC")!
        let components = cal.dateComponents([.year, .month, .day, .hour, .minute], from: feed.tournaments[0].startAtPT!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 5)
        XCTAssertEqual(components.day, 19)
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 10)
    }
}
