import XCTest
@testable import TrackIt

final class StatisticsViewModelTests: XCTestCase {
    func testRefreshAnalyticsUsesLatestRepositoryTasks() {
        let task = TestTaskFactory.make(
            title: "Fresh",
            dateScheduled: RuDate.startOfDay(Date())
        )
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeViewModel(repository: repository)

        repository.tasks[0].isCompleted = true
        viewModel.refreshAnalytics()

        XCTAssertEqual(viewModel.completedCount, 1)
        XCTAssertEqual(viewModel.completionRate, 100)
        XCTAssertEqual(viewModel.analyticsDelta?.improvedFields, Set([.completionRate, .completedCount, .streakDays]))
    }

    func testRepositoryChangePublishesPositiveAnalyticsDelta() {
        let task = TestTaskFactory.make(
            title: "Complete",
            dateScheduled: RuDate.startOfDay(Date())
        )
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeViewModel(repository: repository)

        _ = repository.toggle(task)

        XCTAssertEqual(viewModel.completedCount, 1)
        XCTAssertEqual(viewModel.completionRate, 100)
        XCTAssertEqual(viewModel.analyticsDelta?.improvedFields, Set([.completionRate, .completedCount, .streakDays]))
    }

    func testNegativeAnalyticsChangeDoesNotTriggerCelebrationDelta() {
        let task = TestTaskFactory.make(
            title: "Undo",
            isCompleted: true,
            dateScheduled: RuDate.startOfDay(Date())
        )
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeViewModel(repository: repository)

        _ = repository.toggle(task)

        XCTAssertEqual(viewModel.completedCount, 0)
        XCTAssertNil(viewModel.analyticsDelta)
    }

    private func makeViewModel(repository: MockTaskRepository) -> StatisticsViewModel {
        StatisticsViewModel(
            repository: repository,
            notificationService: MockNotificationService(),
            calendarSyncService: MockCalendarSyncService()
        )
    }
}
