import XCTest
@testable import VegasPokerGuide

final class ReEntryFormatterTests: XCTestCase {
    func testUnlimited() {
        let r = ReEntry(type: .unlimited, count: nil, raw: "UL")
        XCTAssertEqual(ReEntryFormatter.format(r), "Unlimited re-entries")
    }

    func testSingleEntry() {
        let r = ReEntry(type: .singleEntry, count: nil, raw: "0")
        XCTAssertEqual(ReEntryFormatter.format(r), "Single entry")
    }

    func testLimitedOne() {
        let r = ReEntry(type: .limited, count: 1, raw: "1")
        XCTAssertEqual(ReEntryFormatter.format(r), "1 re-entry")
    }

    func testLimitedTwo() {
        let r = ReEntry(type: .limited, count: 2, raw: "2x")
        XCTAssertEqual(ReEntryFormatter.format(r), "2 re-entries")
    }

    func testPerFlightTwo() {
        let r = ReEntry(type: .perFlight, count: 2, raw: "2/fl")
        XCTAssertEqual(ReEntryFormatter.format(r), "2 re-entries per flight")
    }

    func testPerFlightOne() {
        let r = ReEntry(type: .perFlight, count: 1, raw: "1e/fl")
        XCTAssertEqual(ReEntryFormatter.format(r), "1 entry per flight")
    }

    func testUnknownReturnsRaw() {
        let r = ReEntry(type: .unknown, count: nil, raw: "weird?")
        XCTAssertEqual(ReEntryFormatter.format(r), "weird?")
    }

    func testUnknownEmptyReturnsEmDash() {
        let r = ReEntry(type: .unknown, count: nil, raw: "")
        XCTAssertEqual(ReEntryFormatter.format(r), "—")
    }
}
