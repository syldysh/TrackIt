import XCTest
@testable import TrackIt

final class TaskSortingTests: XCTestCase {
    func testPinnedTasksAreDisplayedBeforeUnpinnedTasks() {
        let tasks = [
            makeTask(title: "Regular", pinned: false, time: "08:00"),
            makeTask(title: "Pinned", pinned: true, time: "18:00")
        ]

        let sorted = tasks.sorted(by: Task.displayOrder)

        XCTAssertEqual(sorted.map(\.title), ["Pinned", "Regular"])
    }

    func testTasksKeepTimeOrderInsidePinnedAndRegularGroups() {
        let tasks = [
            makeTask(title: "Regular late", pinned: false, time: "18:00"),
            makeTask(title: "Pinned late", pinned: true, time: "15:00"),
            makeTask(title: "Regular early", pinned: false, time: "09:00"),
            makeTask(title: "Pinned early", pinned: true, time: "08:00"),
            makeTask(title: "Without time", pinned: false, time: nil)
        ]

        let sorted = tasks.sorted(by: Task.displayOrder)

        XCTAssertEqual(
            sorted.map(\.title),
            ["Pinned early", "Pinned late", "Regular early", "Regular late", "Without time"]
        )
    }

    func testPinAndUnpinChangeTaskPriorityThroughCalendarViewModel() {
        let task = makeTask(title: "Priority", pinned: false, time: "10:00")
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = CalendarViewModel(
            repository: repository,
            notificationService: MockNotificationService(),
            calendarSyncService: MockCalendarSyncService()
        )

        viewModel.pin(task)
        XCTAssertTrue(repository.tasks[0].pinned)

        viewModel.pin(repository.tasks[0])
        XCTAssertFalse(repository.tasks[0].pinned)
        XCTAssertEqual(repository.pinCalls.map(\.id), [task.id, task.id])
    }

    func testPinnedTaskCanBeUsedAsUserPriority() {
        let tasks = [
            makeTask(title: "Earlier regular", pinned: false, time: "08:00"),
            makeTask(title: "Later pinned", pinned: true, time: "20:00")
        ]

        let sorted = tasks.sorted(by: Task.displayOrder)

        XCTAssertEqual(sorted.first?.title, "Later pinned")
    }

    private func makeTask(title: String, pinned: Bool, time: String?) -> Task {
        TestTaskFactory.make(
            title: title,
            pinned: pinned,
            dateScheduled: TestTaskFactory.date(day: 13),
            time: time
        )
    }
}
