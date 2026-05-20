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

    // MARK: - entries field tests

    func testEntriesMultipliesTotalIn() {
        let (s, _) = makeStore()
        s.recordPlayed(id: "a", buyIn: 300, cashed: 0, entries: 3)
        let totals = s.playedTotals()
        XCTAssertEqual(totals.totalIn, 900, "totalIn should be buyIn × entries = 300 × 3")
    }

    // MARK: - ROI tests

    func testROIIsNilWhenTotalInIsZero() {
        let (s, _) = makeStore()
        // no records → totalIn = 0
        let totals = s.playedTotals()
        XCTAssertNil(totals.roi, "roi should be nil when totalIn is 0")
    }

    func testROIComputedCorrectly() throws {
        let (s, _) = makeStore()
        // buyIn=100, entries=3 → totalIn=300; cashed=500 → net=200; roi=200/300 ≈ 0.6667
        s.recordPlayed(id: "a", buyIn: 100, cashed: 500, entries: 3)
        let totals = s.playedTotals()
        XCTAssertEqual(totals.totalIn, 300)
        XCTAssertEqual(totals.net, 200)
        let roi = try XCTUnwrap(totals.roi)
        XCTAssertEqual(roi, 200.0 / 300.0, accuracy: 0.0001)
    }

    // MARK: - hourlyRate tests

    func testHourlyRateIsNilWhenTotalHoursIsZero() {
        let (s, _) = makeStore()
        s.recordPlayed(id: "a", buyIn: 200, cashed: 100)  // no hoursPlayed
        let totals = s.playedTotals()
        XCTAssertNil(totals.hourlyRate, "hourlyRate should be nil when totalHours is 0")
    }

    func testHourlyRateComputedCorrectly() throws {
        let (s, _) = makeStore()
        // net = 600 - 400 = 200, hours = 5 → hourlyRate = 40
        s.recordPlayed(id: "a", buyIn: 400, cashed: 600, hoursPlayed: 5.0)
        let totals = s.playedTotals()
        let rate = try XCTUnwrap(totals.hourlyRate)
        XCTAssertEqual(rate, 40.0, accuracy: 0.001)
    }

    // MARK: - Backward compatibility

    func testBackwardCompatDecoding() throws {
        // Encode a JSON dict WITHOUT entries/hoursPlayed keys (simulating old on-disk data)
        let legacyJSON = """
        [{"id":"xyz","buyIn":500,"cashed":0,"recordedAt":0}]
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let records = try decoder.decode([PlayedRecord].self, from: legacyJSON)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].entries, 1, "Missing entries key should default to 1")
        XCTAssertNil(records[0].hoursPlayed, "Missing hoursPlayed key should default to nil")
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
