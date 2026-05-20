import XCTest
@testable import VegasPokerGuide

final class FilterPredicateTests: XCTestCase {
    private func sample(count: Int = 4) -> [Tournament] {
        let cal = Calendar(identifier: .gregorian)
        var c = DateComponents(); c.timeZone = TimeZone(identifier: "America/Los_Angeles")
        c.year = 2026; c.month = 5; c.day = 19
        let date = cal.date(from: c)!
        let start = cal.date(byAdding: .hour, value: 11, to: date)!
        let lr1 = cal.date(byAdding: .hour, value: 17, to: date)!
        let lr2 = cal.date(byAdding: .hour, value: -2, to: start)!  // already closed (9 AM PT)

        return [
            Tournament(id: "a", venue: "venetian", datePT: date, startAtPT: start, lateRegCloseAtPT: lr1,
                       game: "NLH", gameCategory: .nlh, eventName: "NLH 1B", buyInUSD: 600, guaranteeUSD: 150000,
                       reEntry: ReEntry(type: .unlimited, count: nil, raw: "UL"),
                       isDay2: false, flightGroup: "NLH", structurePDFURL: nil, notes: nil),
            Tournament(id: "b", venue: "wynn", datePT: date, startAtPT: start, lateRegCloseAtPT: lr1,
                       game: "PLO", gameCategory: .plo, eventName: "PLO Bounty", buyInUSD: 1100, guaranteeUSD: 50000,
                       reEntry: ReEntry(type: .limited, count: 2, raw: "2"),
                       isDay2: false, flightGroup: "PLO Bounty", structurePDFURL: nil, notes: nil),
            Tournament(id: "c", venue: "wynn", datePT: date, startAtPT: nil, lateRegCloseAtPT: nil,
                       game: "NLH", gameCategory: .nlh, eventName: "NLH Day 2", buyInUSD: nil, guaranteeUSD: nil,
                       reEntry: ReEntry(type: .unknown, count: nil, raw: ""),
                       isDay2: true, flightGroup: "NLH", structurePDFURL: nil, notes: nil),
            Tournament(id: "d", venue: "venetian", datePT: date, startAtPT: start, lateRegCloseAtPT: lr2,
                       game: "NLH", gameCategory: .nlh, eventName: "Mini Mystery", buyInUSD: 550, guaranteeUSD: nil,
                       reEntry: ReEntry(type: .perFlight, count: 2, raw: "2/fl"),
                       isDay2: false, flightGroup: "Mini Mystery", structurePDFURL: nil, notes: nil),
        ]
    }

    func testEmptyFiltersReturnsAllNonDay2() {
        let result = FilterPredicate().apply(to: sample())
        XCTAssertEqual(result.map(\.id), ["a", "b", "d"])  // day-2 hidden by default
    }

    func testIncludeDay2() {
        var f = FilterPredicate()
        f.showDay2 = true
        XCTAssertEqual(f.apply(to: sample()).count, 4)
    }

    func testVenueFilter() {
        var f = FilterPredicate()
        f.venues = ["wynn"]
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["b"])
    }

    func testBuyInRange() {
        var f = FilterPredicate()
        f.minBuyIn = 700
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["b"])
    }

    func testGuaranteeRange() {
        var f = FilterPredicate()
        f.minGuarantee = 100000
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["a"])
    }

    func testGameCategory() {
        var f = FilterPredicate()
        f.gameCategories = [.plo]
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["b"])
    }

    func testReEntryType() {
        var f = FilterPredicate()
        f.reEntryTypes = [.perFlight]
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["d"])
    }

    func testLRStatusOpenNow() {
        var f = FilterPredicate()
        f.lateRegStatus = .openNow
        // 'd' has lr already passed; 'c' has no LR. Only 'a' and 'b' are open.
        let cal = Calendar(identifier: .gregorian)
        var c = DateComponents(); c.timeZone = TimeZone(identifier: "America/Los_Angeles")
        c.year = 2026; c.month = 5; c.day = 19; c.hour = 12
        let now = cal.date(from: c)!
        let result = f.apply(to: sample(), now: now)
        XCTAssertEqual(Set(result.map(\.id)), Set(["a", "b"]))
    }

    func testSearchFuzzyMatchesName() {
        var f = FilterPredicate()
        f.search = "bount"
        XCTAssertEqual(f.apply(to: sample()).map(\.id), ["b"])
    }
}
