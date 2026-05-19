import XCTest
@testable import VegasPokerGuide

final class FavoritesStoreTests: XCTestCase {
    private func makeStore() -> (FavoritesStore, URL) {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return (FavoritesStore(rootDirectory: dir), dir)
    }

    func testStarAndUnstar() {
        let (s, _) = makeStore()
        XCTAssertFalse(s.isStarred("a"))
        s.star("a")
        XCTAssertTrue(s.isStarred("a"))
        s.unstar("a")
        XCTAssertFalse(s.isStarred("a"))
    }

    func testStarringPersistsAcrossInstances() {
        let (s1, dir) = makeStore()
        s1.star("a"); s1.star("b")
        let s2 = FavoritesStore(rootDirectory: dir)
        XCTAssertTrue(s2.isStarred("a"))
        XCTAssertTrue(s2.isStarred("b"))
    }

    func testNotes() {
        let (s, _) = makeStore()
        XCTAssertNil(s.note(for: "a"))
        s.setNote("be there at 10:30", for: "a")
        XCTAssertEqual(s.note(for: "a"), "be there at 10:30")
        s.setNote("", for: "a")
        XCTAssertNil(s.note(for: "a"))
    }

    func testRecordPlayedAndTotals() {
        let (s, _) = makeStore()
        s.recordPlayed(id: "a", buyIn: 600, cashed: 0)
        s.recordPlayed(id: "b", buyIn: 1100, cashed: 4200)
        let totals = s.playedTotals()
        XCTAssertEqual(totals.count, 2)
        XCTAssertEqual(totals.totalIn, 1700)
        XCTAssertEqual(totals.totalCashed, 4200)
        XCTAssertEqual(totals.net, 2500)
    }

    func testUnrecordPlayed() {
        let (s, _) = makeStore()
        s.recordPlayed(id: "a", buyIn: 600, cashed: 0)
        s.unrecordPlayed(id: "a")
        XCTAssertEqual(s.playedTotals().count, 0)
    }

    func testNotificationMappings() {
        let (s, _) = makeStore()
        s.recordNotification(tournamentId: "a", identifier: "notif-a", leadMinutes: 30, fireDate: Date())
        XCTAssertEqual(s.notificationIdentifier(for: "a"), "notif-a")
        s.removeNotification(tournamentId: "a")
        XCTAssertNil(s.notificationIdentifier(for: "a"))
    }
}
