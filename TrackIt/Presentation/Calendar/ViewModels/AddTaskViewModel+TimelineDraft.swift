//
//  AddTaskViewModel+TimelineDraft.swift
//  TrackIt
//
//  Подготовка draft-задачи из дневного таймлайна.
//

import Foundation

extension AddTaskViewModel {
    func prepareAddTask(on date: Date, interval: DayTimelineInterval) {
        editingTask = nil
        newTitle = ""
        newDate = RuDate.startOfDay(date)
        addDateMode = 2
        showTimePicker = true
        showDurationPicker = true
        newDuration = Int16(interval.durationMinutes)
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
        timeDate = RuDate.calendar.date(
            byAdding: .minute,
            value: interval.startMinutes,
            to: newDate
        ) ?? newDate
        showAddTask = true
    }
}
