import Combine
import Foundation
@testable import TrackIt

final class MockTaskRepository: TaskRepositoryProtocol {
    struct AddScheduledTaskCall {
        let title: String
        let date: Date
        let time: String?
        let duration: Int16
        let reminderEnabled: Bool
        let calendarSyncEnabled: Bool
    }

    struct ScheduleFromInboxCall {
        let task: Task
        let date: Date
        let time: String?
        let duration: Int16
        let reminderEnabled: Bool
        let calendarSyncEnabled: Bool
    }

    struct UpdateCall {
        let task: Task
        let title: String
        let date: Date
        let time: String?
        let duration: Int16
        let reminderEnabled: Bool
        let calendarSyncEnabled: Bool
    }

    var tasks: [Task]
    var addInboxTaskCalls: [String] = []
    var addScheduledTaskCalls: [AddScheduledTaskCall] = []
    var toggleCalls: [Task] = []
    var pinCalls: [Task] = []
    var deleteCalls: [Task] = []
    var scheduleFromInboxCalls: [ScheduleFromInboxCall] = []
    var updateCalls: [UpdateCall] = []
    var updateInboxTitleCalls: [(task: Task, title: String)] = []
    var setTimeCalls: [(time: String?, task: Task)] = []
    var updateCalendarEventIdentifierCalls: [(identifier: String?, taskID: UUID)] = []

    private let changes = PassthroughSubject<Void, Never>()

    init(tasks: [Task] = []) {
        self.tasks = tasks
    }

    var inboxTasks: [Task] {
        tasks.filter(\.isInbox).sorted(by: Task.displayOrder)
    }

    var scheduledTasks: [Task] {
        tasks.filter { !$0.isInbox }
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var changePublisher: AnyPublisher<Void, Never> {
        changes.eraseToAnyPublisher()
    }

    func tasks(for date: Date) -> [Task] {
        scheduledTasks
            .filter { task in
                guard let scheduled = task.dateScheduled else { return false }
                return RuDate.calendar.isDate(scheduled, inSameDayAs: date)
            }
            .sorted(by: Task.displayOrder)
    }

    @discardableResult
    func addInboxTask(title: String) -> Task {
        addInboxTaskCalls.append(title)
        let task = TestTaskFactory.make(title: title, isInbox: true)
        tasks.append(task)
        changes.send()
        return task
    }

    @discardableResult
    func addScheduledTask(
        title: String,
        date: Date,
        time: String?,
        duration: Int16,
        reminderEnabled: Bool,
        calendarSyncEnabled: Bool
    ) -> Task {
        addScheduledTaskCalls.append(
            AddScheduledTaskCall(
                title: title,
                date: date,
                time: time,
                duration: duration,
                reminderEnabled: reminderEnabled,
                calendarSyncEnabled: calendarSyncEnabled
            )
        )
        let task = TestTaskFactory.make(
            title: title,
            isInbox: false,
            dateScheduled: date,
            time: time,
            duration: duration,
            reminderEnabled: reminderEnabled,
            calendarSyncEnabled: calendarSyncEnabled
        )
        tasks.append(task)
        changes.send()
        return task
    }

    @discardableResult
    func toggle(_ task: Task) -> Task? {
        toggleCalls.append(task)
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return nil }
        tasks[index].isCompleted.toggle()
        changes.send()
        return tasks[index]
    }

    func pin(_ task: Task) {
        pinCalls.append(task)
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].pinned.toggle()
        changes.send()
    }

    func delete(_ task: Task) {
        deleteCalls.append(task)
        tasks.removeAll { $0.id == task.id }
        changes.send()
    }

    @discardableResult
    func updateInboxTitle(_ task: Task, title: String) -> Task? {
        updateInboxTitleCalls.append((task, title))
        guard let index = tasks.firstIndex(where: { $0.id == task.id }), tasks[index].isInbox else {
            return nil
        }
        tasks[index].title = title
        changes.send()
        return tasks[index]
    }

    @discardableResult
    func setTime(_ time: String?, for task: Task) -> Task? {
        setTimeCalls.append((time, task))
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return nil }
        tasks[index].time = time
        if (time ?? "").isEmpty {
            tasks[index].reminderEnabled = false
            tasks[index].calendarSyncEnabled = false
        }
        changes.send()
        return tasks[index]
    }

    @discardableResult
    func scheduleFromInbox(
        _ task: Task,
        date: Date,
        time: String?,
        duration: Int16,
        reminderEnabled: Bool,
        calendarSyncEnabled: Bool
    ) -> Task? {
        scheduleFromInboxCalls.append(
            ScheduleFromInboxCall(
                task: task,
                date: date,
                time: time,
                duration: duration,
                reminderEnabled: reminderEnabled,
                calendarSyncEnabled: calendarSyncEnabled
            )
        )
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return nil }
        tasks[index].isInbox = false
        tasks[index].dateScheduled = date
        tasks[index].time = time
        tasks[index].duration = duration
        tasks[index].reminderEnabled = reminderEnabled
        tasks[index].calendarSyncEnabled = calendarSyncEnabled
        changes.send()
        return tasks[index]
    }

    @discardableResult
    func update(
        _ task: Task,
        title: String,
        date: Date,
        time: String?,
        duration: Int16,
        reminderEnabled: Bool,
        calendarSyncEnabled: Bool
    ) -> Task? {
        updateCalls.append(
            UpdateCall(
                task: task,
                title: title,
                date: date,
                time: time,
                duration: duration,
                reminderEnabled: reminderEnabled,
                calendarSyncEnabled: calendarSyncEnabled
            )
        )
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return nil }
        tasks[index].title = title
        tasks[index].dateScheduled = date
        tasks[index].time = time
        tasks[index].duration = duration
        tasks[index].isInbox = false
        tasks[index].reminderEnabled = reminderEnabled
        tasks[index].calendarSyncEnabled = calendarSyncEnabled
        changes.send()
        return tasks[index]
    }

    @discardableResult
    func updateCalendarEventIdentifier(_ identifier: String?, for taskID: UUID) -> Task? {
        updateCalendarEventIdentifierCalls.append((identifier, taskID))
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return nil }
        tasks[index].calendarEventIdentifier = identifier
        changes.send()
        return tasks[index]
    }
}
