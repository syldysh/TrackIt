import XCTest
@testable import TrackIt

final class StatisticsServiceTests: XCTestCase {
    private let referenceDate = TestTaskFactory.date(day: 13)

    func testCompletionRateIsZeroWhenThereAreNoTasks() {
        // given
        let tasks: [Task] = []

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.progress.completionRate, 0)
    }

    func testCompletionRateIsHundredWhenAllTasksAreCompleted() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.progress.completionRate, 100)
    }

    func testCompletionRateUsesRoundedPercentageForPartiallyCompletedTasks() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: false)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.progress.completionRate, 67)
    }

    func testTasksOutsideCurrentWeekDoNotAffectWeeklyStatistics() {
        // given
        let tasks = [
            scheduledTask(day: 4, isCompleted: true),
            scheduledTask(day: 12, isCompleted: false)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.progress.completedCount, 0)
        XCTAssertEqual(snapshot.progress.totalCount, 1)
    }

    func testCompletedCountAndTotalCountAreCalculatedForCurrentWeek() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: false),
            scheduledTask(day: 13, isCompleted: true),
            TestTaskFactory.make(title: "Inbox", isCompleted: true, isInbox: true)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.progress.completedCount, 2)
        XCTAssertEqual(snapshot.progress.totalCount, 3)
    }

    func testStreakIsZeroWhenThereAreNoCompletedTasks() {
        // given
        let tasks = [
            scheduledTask(day: 12, isCompleted: false),
            scheduledTask(day: 13, isCompleted: false)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.streak.days, 0)
        XCTAssertNil(snapshot.streak.countedThrough)
    }

    func testStreakCountsConsecutiveCompletedDays() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.streak.days, 3)
        XCTAssertEqual(snapshot.streak.countedThrough, TestTaskFactory.date(day: 13))
    }

    func testStreakStopsWhenThereIsGapBetweenCompletedDays() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.streak.days, 1)
    }

    func testBestProductivityDayPrefersHigherCompletionAndThenMoreCompletedTasks() {
        // given
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 11, isCompleted: false),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        // when
        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        // then
        XCTAssertEqual(snapshot.bestProductivityDay?.date, TestTaskFactory.date(day: 13))
        XCTAssertEqual(snapshot.bestProductivityDay?.completedCount, 2)
        XCTAssertEqual(snapshot.bestProductivityDay?.completionRate, 100)
    }

    private func scheduledTask(day: Int, isCompleted: Bool) -> Task {
        TestTaskFactory.make(
            isCompleted: isCompleted,
            dateScheduled: TestTaskFactory.date(day: day)
        )
    }
}
