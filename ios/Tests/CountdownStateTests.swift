import XCTest
@testable import VegasPokerGuide

final class CountdownStateTests: XCTestCase {
    private func date(_ secondsFromNow: TimeInterval, base: Date = Date()) -> Date {
        base.addingTimeInterval(secondsFromNow)
    }

    // Helper: a startAt one minute before `now` so the event is "running today, just barely".
    private func runningStart(now: Date) -> Date { now.addingTimeInterval(-60) }

    func testGreenWhenMoreThanTwoHours() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(3 * 3600, base: now), now: now)
        XCTAssertEqual(state.tier, .green)
        XCTAssertFalse(state.isClosed)
    }

    func testAmberWhenLessThanTwoHoursMoreThanThirty() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(45 * 60, base: now), now: now)
        XCTAssertEqual(state.tier, .amber)
    }

    func testRedWhenLessThanThirtyMinutes() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(20 * 60, base: now), now: now)
        XCTAssertEqual(state.tier, .red)
    }

    func testClosedWhenLRPassed() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(-60, base: now), now: now)
        XCTAssertEqual(state.tier, .closed)
        XCTAssertTrue(state.isClosed)
    }

    func testNilLateRegBecomesUnknown() {
        let state = CountdownState.compute(startAt: runningStart(now: Date()), lateRegClose: nil, now: Date())
        XCTAssertEqual(state.tier, .unknown)
        XCTAssertFalse(state.isVisible)
    }

    func testNotRunningWhenStartIsInFutureToday() {
        let now = Date()
        let state = CountdownState.compute(startAt: date(3 * 3600, base: now), lateRegClose: date(6 * 3600, base: now), now: now)
        XCTAssertEqual(state.tier, .notRunning)
        XCTAssertFalse(state.isVisible)
    }

    func testNotRunningWhenStartIsOnDifferentPTDay() {
        // Build a "now" in PT mid-day, and an event start one calendar day later in PT.
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        var comps = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles")!, year: 2026, month: 5, day: 19, hour: 12)
        let now = cal.date(from: comps)!
        comps.day = 20; comps.hour = 11
        let startTomorrow = cal.date(from: comps)!
        let close = startTomorrow.addingTimeInterval(6 * 3600)
        let state = CountdownState.compute(startAt: startTomorrow, lateRegClose: close, now: now)
        XCTAssertEqual(state.tier, .notRunning)
    }

    func testNotRunningWhenStartIsNil() {
        // No start time → can't decide; treat as not running.
        let now = Date()
        let state = CountdownState.compute(startAt: nil, lateRegClose: date(3 * 3600, base: now), now: now)
        XCTAssertEqual(state.tier, .notRunning)
    }

    func testFormatsHoursMinutesSeconds() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(3 * 3600 + 22 * 60 + 14, base: now), now: now)
        XCTAssertEqual(state.text, "3h 22m 14s")
    }

    func testFormatsMinutesSecondsUnderOneHour() {
        let now = Date()
        let state = CountdownState.compute(startAt: runningStart(now: now), lateRegClose: date(45 * 60 + 12, base: now), now: now)
        XCTAssertEqual(state.text, "45m 12s")
    }
}
