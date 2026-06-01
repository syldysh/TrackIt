import XCTest
@testable import TrackIt

final class DayTimelineMetricsTests: XCTestCase {
    private let metrics = DayTimelineMetrics(hourHeight: 60)

    func testYPositionConvertsToMinutesFromStart() {
        XCTAssertEqual(metrics.minutesFromStart(forY: 90), 90)
    }

    func testMinutesFromStartConvertsToYPosition() {
        XCTAssertEqual(metrics.yPosition(forMinutesFromStart: 150), 150)
    }

    func testSnapRoundsNearbySevenMinutesDownToHour() {
        XCTAssertEqual(metrics.snappedMinutes(19 * 60 + 7), 19 * 60)
    }

    func testSnapRoundsNearbyTwentyTwoMinutesToFifteen() {
        XCTAssertEqual(metrics.snappedMinutes(19 * 60 + 22), 19 * 60 + 15)
    }

    func testSnapRoundsNearbyThirtyEightMinutesToFortyFive() {
        XCTAssertEqual(metrics.snappedMinutes(19 * 60 + 38), 19 * 60 + 45)
    }

    func testDefaultIntervalNearNineteenTenStartsAtNineteenFifteen() {
        let interval = metrics.defaultInterval(forY: CGFloat(19 * 60 + 10))

        XCTAssertEqual(interval.startMinutes, 19 * 60 + 15)
        XCTAssertEqual(interval.endMinutes, 20 * 60 + 15)
        XCTAssertEqual(interval.durationMinutes, 60)
    }

    func testHeightUsesMinimumDuration() {
        XCTAssertEqual(metrics.height(forDurationMinutes: 10), 30)
    }

    func testMovingKeepsDuration() {
        let interval = metrics.intervalByMoving(
            startMinutes: 9 * 60,
            endMinutes: 10 * 60,
            translationY: 90
        )

        XCTAssertEqual(interval.startMinutes, 10 * 60 + 30)
        XCTAssertEqual(interval.endMinutes, 11 * 60 + 30)
        XCTAssertEqual(interval.durationMinutes, 60)
    }

    func testMovingClampsToEndOfDay() {
        let interval = metrics.intervalByMoving(
            startMinutes: 23 * 60,
            endMinutes: 24 * 60,
            translationY: 120
        )

        XCTAssertEqual(interval.startMinutes, 23 * 60)
        XCTAssertEqual(interval.endMinutes, 24 * 60)
    }

    func testResizeTopKeepsMinimumDuration() {
        let interval = metrics.intervalByResizingTop(
            startMinutes: 9 * 60,
            endMinutes: 10 * 60,
            translationY: 45
        )

        XCTAssertEqual(interval.startMinutes, 9 * 60 + 30)
        XCTAssertEqual(interval.endMinutes, 10 * 60)
        XCTAssertEqual(interval.durationMinutes, 30)
    }

    func testResizeBottomKeepsMinimumDuration() {
        let interval = metrics.intervalByResizingBottom(
            startMinutes: 9 * 60,
            endMinutes: 10 * 60,
            translationY: -45
        )

        XCTAssertEqual(interval.startMinutes, 9 * 60)
        XCTAssertEqual(interval.endMinutes, 9 * 60 + 30)
        XCTAssertEqual(interval.durationMinutes, 30)
    }

    func testDefaultIntervalNearEndOfDayClampsToBounds() {
        let interval = metrics.defaultInterval(forY: CGFloat(23 * 60 + 50))

        XCTAssertEqual(interval.startMinutes, 23 * 60)
        XCTAssertEqual(interval.endMinutes, 24 * 60)
    }
}
