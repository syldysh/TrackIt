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

    func testPreparingTimelineDraftPrefillsTimeAndDurationWithoutSaving() {
        let repository = MockTaskRepository()
        let viewModel = makeCalendarViewModel(repository: repository)
        let date = TestTaskFactory.date(day: 14)
        let interval = DayTimelineInterval(startMinutes: 19 * 60 + 15, endMinutes: 20 * 60 + 15)

        viewModel.addTaskVM.prepareAddTask(on: date, interval: interval)

        XCTAssertTrue(viewModel.addTaskVM.showAddTask)
        XCTAssertTrue(viewModel.addTaskVM.showTimePicker)
        XCTAssertTrue(viewModel.addTaskVM.showDurationPicker)
        XCTAssertEqual(viewModel.addTaskVM.newDuration, 60)
        XCTAssertEqual(viewModel.addTaskVM.newTitle, "")
        XCTAssertEqual(RuDate.startOfDay(viewModel.addTaskVM.newDate), RuDate.startOfDay(date))
        XCTAssertEqual(RuDate.calendar.component(.hour, from: viewModel.addTaskVM.timeDate), 19)
        XCTAssertEqual(RuDate.calendar.component(.minute, from: viewModel.addTaskVM.timeDate), 15)
        XCTAssertTrue(repository.addScheduledTaskCalls.isEmpty)
    }

    func testWhitespaceAndNewlineTitleCannotBeSaved() {
        let repository = MockTaskRepository()
        let viewModel = makeCalendarViewModel(repository: repository)
        let date = TestTaskFactory.date(day: 14)
        let interval = DayTimelineInterval(startMinutes: 9 * 60, endMinutes: 10 * 60)

        viewModel.addTaskVM.prepareAddTask(on: date, interval: interval)
        viewModel.addTaskVM.newTitle = " \n "
        viewModel.addTaskVM.commitAddTask()

        XCTAssertFalse(viewModel.addTaskVM.canAddTask)
        XCTAssertTrue(repository.addScheduledTaskCalls.isEmpty)
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

    func testMarkingCompletedTaskIncompleteFromStatisticsUpdatesSharedTaskAndSnapshot() {
        let scheduledDate = RuDate.startOfDay(Date())
        let task = TestTaskFactory.make(
            title: "Done",
            isCompleted: true,
            dateScheduled: scheduledDate,
            time: "09:00",
            duration: 30,
            reminderEnabled: true,
            calendarSyncEnabled: true
        )
        let repository = MockTaskRepository(tasks: [task])
        let notificationService = MockNotificationService()
        let calendarSyncService = MockCalendarSyncService()
        let viewModel = StatisticsViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )

        viewModel.markTaskIncomplete(task)

        let updatedTask = repository.tasks.first
        XCTAssertEqual(repository.toggleCalls.map(\.id), [task.id])
        XCTAssertEqual(updatedTask?.isCompleted, false)
        XCTAssertEqual(updatedTask?.dateScheduled, scheduledDate)
        XCTAssertEqual(updatedTask?.time, "09:00")
        XCTAssertEqual(updatedTask?.duration, 30)
        XCTAssertTrue(viewModel.completedTasks.isEmpty)
        XCTAssertEqual(viewModel.completedCount, 0)
        XCTAssertEqual(notificationService.syncedTasks.first?.isCompleted, false)
        XCTAssertEqual(calendarSyncService.syncedTasks.first?.isCompleted, false)
    }

    func testMarkingIncompleteTaskIncompleteFromStatisticsDoesNothing() {
        let task = TestTaskFactory.make(
            title: "Active",
            isCompleted: false,
            dateScheduled: RuDate.startOfDay(Date())
        )
        let repository = MockTaskRepository(tasks: [task])
        let notificationService = MockNotificationService()
        let calendarSyncService = MockCalendarSyncService()
        let viewModel = StatisticsViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )

        viewModel.markTaskIncomplete(task)

        XCTAssertTrue(repository.toggleCalls.isEmpty)
        XCTAssertTrue(notificationService.syncedTasks.isEmpty)
        XCTAssertTrue(calendarSyncService.syncedTasks.isEmpty)
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
