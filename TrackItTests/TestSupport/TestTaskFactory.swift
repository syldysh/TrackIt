import Foundation
@testable import TrackIt

enum TestTaskFactory {
    static func make(
        id: UUID = UUID(),
        title: String = "Task",
        isCompleted: Bool = false,
        isInbox: Bool = false,
        pinned: Bool = false,
        dateScheduled: Date? = nil,
        time: String? = nil,
        duration: Int16 = 0,
        reminderEnabled: Bool = false,
        calendarSyncEnabled: Bool = false,
        calendarEventIdentifier: String? = nil
    ) -> Task {
        Task(
            id: id,
            title: title,
            isCompleted: isCompleted,
            isInbox: isInbox,
            pinned: pinned,
            dateScheduled: dateScheduled,
            time: time,
            duration: duration,
            reminderEnabled: reminderEnabled,
            calendarSyncEnabled: calendarSyncEnabled,
            calendarEventIdentifier: calendarEventIdentifier
        )
    }

    static func date(
        year: Int = 2026,
        month: Int = 5,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) -> Date {
        RuDate.calendar.date(
            from: DateComponents(
                calendar: RuDate.calendar,
                timeZone: RuDate.calendar.timeZone,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
        )!
    }
}
