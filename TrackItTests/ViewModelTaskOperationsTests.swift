import XCTest
@testable import TrackIt

final class ViewModelTaskOperationsTests: XCTestCase {
    func testCreatingInboxTaskCallsAddInboxTaskWithTrimmedTitle() {
        // given
        let repository = MockTaskRepository()
        let viewModel = makeInboxViewModel(repository: repository)
        viewModel.newText = "  Read docs  "

        // when
        viewModel.commitTask()

        // then
        XCTAssertEqual(repository.addInboxTaskCalls, ["Read docs"])
        XCTAssertEqual(viewModel.newText, "")
    }

    func testSchedulingInboxTaskCallsScheduleFromInboxWithParameters() {
        // given
        let task = TestTaskFactory.make(title: "Inbox", isInbox: true)
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeInboxViewModel(repository: repository)
        let date = TestTaskFactory.date(day: 14)

        // when
        viewModel.scheduleFromInbox(
            task,
            date: date,
            time: "09:30",
            duration: 45,
            reminderEnabled: true,
            calendarSyncEnabled: false
        )

        // then
        let call = repository.scheduleFromInboxCalls.first
        XCTAssertEqual(call?.task.id, task.id)
        XCTAssertEqual(call?.date, date)
        XCTAssertEqual(call?.time, "09:30")
        XCTAssertEqual(call?.duration, 45)
        XCTAssertEqual(call?.reminderEnabled, true)
        XCTAssertEqual(call?.calendarSyncEnabled, false)
    }

    func testDeletingTaskCallsRepositoryDelete() {
        // given
        let task = TestTaskFactory.make(title: "Delete me", isInbox: true)
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeInboxViewModel(repository: repository)

        // when
        viewModel.delete(task)

        // then
        XCTAssertEqual(repository.deleteCalls.map(\.id), [task.id])
    }

    func testCompletingTaskCallsRepositoryToggle() {
        // given
        let task = TestTaskFactory.make(
            title: "Complete me",
            dateScheduled: TestTaskFactory.date(day: 13)
        )
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeCalendarViewModel(repository: repository)

        // when
        viewModel.toggle(task)

        // then
        XCTAssertEqual(repository.toggleCalls.map(\.id), [task.id])
        XCTAssertEqual(repository.tasks.first?.isCompleted, true)
    }

    func testPinningTaskCallsRepositoryPin() {
        // given
        let task = TestTaskFactory.make(
            title: "Pin me",
            dateScheduled: TestTaskFactory.date(day: 13)
        )
        let repository = MockTaskRepository(tasks: [task])
        let viewModel = makeCalendarViewModel(repository: repository)

        // when
        viewModel.pin(task)

        // then
        XCTAssertEqual(repository.pinCalls.map(\.id), [task.id])
    }

    private func makeInboxViewModel(repository: MockTaskRepository) -> InboxViewModel {
        InboxViewModel(
            repository: repository,
            notificationService: MockNotificationService(),
            calendarSyncService: MockCalendarSyncService()
        )
    }

    private func makeCalendarViewModel(repository: MockTaskRepository) -> CalendarViewModel {
        CalendarViewModel(
            repository: repository,
            notificationService: MockNotificationService(),
            calendarSyncService: MockCalendarSyncService()
        )
    }
}
