import XCTest
@testable import VegasPokerGuide

final class CountdownStateTests: XCTestCase {
    private func date(_ secondsFromNow: TimeInterval, base: Date = Date()) -> Date {
        base.addingTimeInterval(secondsFromNow)
    }

    func testGreenWhenMoreThanTwoHours() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(3 * 3600, base: now), now: now)
        XCTAssertEqual(state.tier, .green)
        XCTAssertFalse(state.isClosed)
    }

    func testAmberWhenLessThanTwoHoursMoreThanThirty() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(45 * 60, base: now), now: now)
        XCTAssertEqual(state.tier, .amber)
    }

    func testRedWhenLessThanThirtyMinutes() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(20 * 60, base: now), now: now)
        XCTAssertEqual(state.tier, .red)
    }

    func testGreyWhenClosed() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(-60, base: now), now: now)
        XCTAssertEqual(state.tier, .closed)
        XCTAssertTrue(state.isClosed)
    }

    func testNilLateRegBecomesUnknown() {
        let state = CountdownState.compute(lateRegClose: nil, now: Date())
        XCTAssertEqual(state.tier, .unknown)
    }

    func testFormatsHoursMinutesSeconds() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(3 * 3600 + 22 * 60 + 14, base: now), now: now)
        XCTAssertEqual(state.text, "3h 22m 14s")
    }

    func testFormatsMinutesSecondsUnderOneHour() {
        let now = Date()
        let state = CountdownState.compute(lateRegClose: date(45 * 60 + 12, base: now), now: now)
        XCTAssertEqual(state.text, "45m 12s")
    }
}
