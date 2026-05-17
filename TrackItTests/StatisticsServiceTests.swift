import XCTest
@testable import TrackIt

final class StatisticsServiceTests: XCTestCase {
    private let referenceDate = TestTaskFactory.date(day: 13)

    func testCompletionRateIsZeroWhenThereAreNoTasks() {
        let snapshot = StatisticsService.snapshot(tasks: [], referenceDate: referenceDate)

        XCTAssertEqual(snapshot.progress.completionRate, 0)
    }

    func testCompletionRateIsHundredWhenAllTasksAreCompleted() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.progress.completionRate, 100)
    }

    func testCompletionRateUsesRoundedPercentageForPartiallyCompletedTasks() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: false)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.progress.completionRate, 67)
    }

    func testTasksOutsideCurrentWeekDoNotAffectWeeklyStatistics() {
        let tasks = [
            scheduledTask(day: 4, isCompleted: true),
            scheduledTask(day: 12, isCompleted: false)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.progress.completedCount, 0)
        XCTAssertEqual(snapshot.progress.totalCount, 1)
    }

    func testCompletedCountAndTotalCountAreCalculatedForCurrentWeek() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: false),
            scheduledTask(day: 13, isCompleted: true),
            TestTaskFactory.make(title: "Inbox", isCompleted: true, isInbox: true)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.progress.completedCount, 2)
        XCTAssertEqual(snapshot.progress.totalCount, 3)
    }

    func testStreakIsZeroWhenThereAreNoCompletedTasks() {
        let tasks = [
            scheduledTask(day: 12, isCompleted: false),
            scheduledTask(day: 13, isCompleted: false)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.streak.days, 0)
        XCTAssertNil(snapshot.streak.countedThrough)
    }

    func testStreakCountsConsecutiveCompletedDays() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.streak.days, 3)
        XCTAssertEqual(snapshot.streak.countedThrough, TestTaskFactory.date(day: 13))
    }

    func testStreakStopsWhenThereIsGapBetweenCompletedDays() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

        XCTAssertEqual(snapshot.streak.days, 1)
    }

    func testBestProductivityDayPrefersHigherCompletionAndThenMoreCompletedTasks() {
        let tasks = [
            scheduledTask(day: 11, isCompleted: true),
            scheduledTask(day: 11, isCompleted: false),
            scheduledTask(day: 12, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true),
            scheduledTask(day: 13, isCompleted: true)
        ]

        let snapshot = StatisticsService.snapshot(tasks: tasks, referenceDate: referenceDate)

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
