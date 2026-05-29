import XCTest
@testable import TrackIt

final class NotificationLogicTests: XCTestCase {
    func testCreatingScheduledTaskWithReminderSyncsNotification() {
        // given
        let repository = MockTaskRepository()
        let notificationService = MockNotificationService()
        let viewModel = AddTaskViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: MockCalendarSyncService()
        )
        viewModel.newTitle = "Call"
        viewModel.newDate = futureDate(dayOffset: 1)
        viewModel.showTimePicker = true
        viewModel.timeDate = TestTaskFactory.date(day: 18, hour: 10, minute: 30)
        viewModel.reminderEnabled = true

        // when
        viewModel.commitAddTask()

        // then
        XCTAssertEqual(notificationService.syncedTasks.count, 1)
        XCTAssertEqual(notificationService.syncedTasks.first?.title, "Call")
        XCTAssertEqual(notificationService.syncedTasks.first?.time, "10:30")
        XCTAssertEqual(notificationService.syncedTasks.first?.reminderEnabled, true)
    }

    func testEditingScheduledTaskWithReminderSyncsNotification() {
        // given
        let task = TestTaskFactory.make(
            title: "Old",
            dateScheduled: futureDate(dayOffset: 1),
            time: "08:00"
        )
        let repository = MockTaskRepository(tasks: [task])
        let notificationService = MockNotificationService()
        let viewModel = AddTaskViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: MockCalendarSyncService()
        )
        viewModel.prepareEditTask(task)
        viewModel.newTitle = "Updated"
        viewModel.showTimePicker = true
        viewModel.timeDate = TestTaskFactory.date(day: 18, hour: 11, minute: 45)
        viewModel.reminderEnabled = true

        // when
        viewModel.commitAddTask()

        // then
        XCTAssertEqual(notificationService.syncedTasks.count, 1)
        XCTAssertEqual(notificationService.syncedTasks.first?.title, "Updated")
        XCTAssertEqual(notificationService.syncedTasks.first?.time, "11:45")
        XCTAssertEqual(notificationService.syncedTasks.first?.reminderEnabled, true)
    }

    func testDeletingTaskCancelsNotification() {
        // given
        let task = TestTaskFactory.make(
            title: "Delete",
            dateScheduled: futureDate(dayOffset: 1),
            time: "09:00",
            reminderEnabled: true
        )
        let repository = MockTaskRepository(tasks: [task])
        let notificationService = MockNotificationService()
        let viewModel = CalendarViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: MockCalendarSyncService()
        )

        // when
        viewModel.delete(task)

        // then
        XCTAssertEqual(notificationService.cancelledTaskIDs, [task.id])
    }

    func testCompletingTaskResyncsNotificationWithCompletedState() {
        // given
        let task = TestTaskFactory.make(
            title: "Complete",
            dateScheduled: futureDate(dayOffset: 1),
            time: "09:00",
            reminderEnabled: true
        )
        let repository = MockTaskRepository(tasks: [task])
        let notificationService = MockNotificationService()
        let viewModel = CalendarViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: MockCalendarSyncService()
        )

        // when
        viewModel.toggle(task)

        // then
        XCTAssertEqual(notificationService.syncedTasks.first?.id, task.id)
        XCTAssertEqual(notificationService.syncedTasks.first?.isCompleted, true)
    }

    func testReminderDisabledDoesNotProduceNotificationFireDate() {
        // given
        let task = TestTaskFactory.make(
            title: "No reminder",
            dateScheduled: futureDate(dayOffset: 1),
            time: "09:00",
            reminderEnabled: false
        )

        // when
        let fireDate = NotificationSchedulingPolicy.fireDate(for: task, now: Date())

        // then
        XCTAssertNil(fireDate)
    }

    private static func futureDate(dayOffset: Int) -> Date {
        RuDate.addDays(RuDate.startOfDay(Date()), dayOffset)
    }

    private func futureDate(dayOffset: Int) -> Date {
        Self.futureDate(dayOffset: dayOffset)
    }
}
