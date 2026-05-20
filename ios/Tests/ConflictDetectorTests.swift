import XCTest
@testable import VegasPokerGuide

final class ConflictDetectorTests: XCTestCase {
    private func t(id: String, start: Date, lr: Date) -> Tournament {
        Tournament(id: id, venue: "venetian",
                   datePT: start, startAtPT: start, lateRegCloseAtPT: lr,
                   game: "NLH", gameCategory: .nlh, eventName: id,
                   buyInUSD: 600, guaranteeUSD: nil,
                   reEntry: ReEntry(type: .unlimited, count: nil, raw: "UL"),
                   isDay2: false, flightGroup: "NLH", structurePDFURL: nil, notes: nil)
    }

    func testNoOverlap() {
        let now = Date()
        let a = t(id: "a", start: now, lr: now.addingTimeInterval(3600))
        let b = t(id: "b", start: now.addingTimeInterval(7200), lr: now.addingTimeInterval(10800))
        XCTAssertEqual(ConflictDetector.findConflicts(in: [a, b]).count, 0)
    }

    func testOverlap() {
        let now = Date()
        let a = t(id: "a", start: now, lr: now.addingTimeInterval(2 * 3600))
        let b = t(id: "b", start: now.addingTimeInterval(3600), lr: now.addingTimeInterval(3 * 3600))
        let c = ConflictDetector.findConflicts(in: [a, b])
        XCTAssertEqual(c.count, 1)
        XCTAssertEqual(Set([c[0].0, c[0].1]), Set(["a", "b"]))
    }

    func testIgnoresMissingTimes() {
        let now = Date()
        let a = t(id: "a", start: now, lr: now.addingTimeInterval(3600))
        var b = a
        b = Tournament(id: "b", venue: "wynn", datePT: now, startAtPT: nil, lateRegCloseAtPT: nil,
                       game: "NLH", gameCategory: .nlh, eventName: "b", buyInUSD: nil, guaranteeUSD: nil,
                       reEntry: ReEntry(type: .unknown, count: nil, raw: ""), isDay2: false, flightGroup: "",
                       structurePDFURL: nil, notes: nil)
        XCTAssertEqual(ConflictDetector.findConflicts(in: [a, b]).count, 0)
    }
}
