//
//  AddTaskViewModel.swift
//  TrackIt
//
//  Форм-стейт для добавления / редактирования задачи.
//  Выделен из CalendarViewModel, чтобы снять с него лишние ответственности.
//

import Foundation
import Combine

final class AddTaskViewModel: ObservableObject {

    // MARK: - Состояние формы

    @Published var showAddTask = false
    @Published var editingTask: Task? = nil
    @Published var newTitle = ""
    @Published var newDate: Date = RuDate.startOfDay(Date())
    @Published var showTimePicker = false
    @Published var timeDate = Date()
    @Published var addDateMode: Int = 0
    @Published var newDuration: Int16 = 0
    @Published var showDurationPicker = false
    @Published var reminderEnabled = false
    @Published var notificationPermissionMessage: String? = nil
    @Published var calendarSyncEnabled = false
    @Published var calendarPermissionMessage: String? = nil

    // MARK: - Зависимости

    let repository: any TaskRepositoryProtocol
    let notificationService: any NotificationServiceProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol

    // MARK: - Init

    init(
        repository: any TaskRepositoryProtocol,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService
    }

    // MARK: - Вычисляемые свойства

    var canAddTask: Bool {
        !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canShowReminderToggle: Bool {
        showTimePicker
    }

    var canShowCalendarSyncToggle: Bool {
        showTimePicker
    }

    var isEditingInboxTask: Bool {
        editingTask?.isInbox == true
    }

    // MARK: - Открыть форму (новая задача)

    func prepareAddTask(selectedDate: Date) {
        let today = RuDate.startOfDay(Date())
        let tomorrow = RuDate.addDays(today, 1)
        if selectedDate >= today {
            newDate = selectedDate
            if RuDate.isoString(from: selectedDate) == RuDate.isoString(from: today) {
                addDateMode = 0
            } else if RuDate.isoString(from: selectedDate) == RuDate.isoString(from: tomorrow) {
                addDateMode = 1
            } else {
                addDateMode = 2
            }
        } else {
            newDate = today
            addDateMode = 0
        }
        showTimePicker = false
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
        showAddTask = true
    }

    // Тап по сетке дня без конкретной даты
    func prepareAddTaskAt(hour: Int, minute: Int) {
        prepareAddTask(selectedDate: newDate)
        showTimePicker = true
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
        var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: newDate)
        comps.hour = hour
        comps.minute = minute
        timeDate = RuDate.calendar.date(from: comps) ?? Date()
    }

    // Тап по сетке в модальном окне — конкретная дата
    func prepareAddTaskAt(hour: Int, minute: Int, date: Date) {
        newDate = RuDate.startOfDay(date)
        addDateMode = 2
        showAddTask = true
        newTitle = ""
        showTimePicker = true
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
        var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = minute
        timeDate = RuDate.calendar.date(from: comps) ?? Date()
    }

    // MARK: - Открыть форму (редактирование существующей задачи)

    func prepareEditTask(_ task: Task) {
        editingTask = task
        newTitle = task.title

        guard !task.isInbox else {
            newDate = RuDate.startOfDay(Date())
            addDateMode = 0
            showTimePicker = false
            newDuration = 0
            showDurationPicker = false
            reminderEnabled = false
            notificationPermissionMessage = nil
            calendarSyncEnabled = false
            calendarPermissionMessage = nil
            showAddTask = true
            return
        }

        let date = task.dateScheduled ?? RuDate.startOfDay(Date())
        newDate = date
        let today = RuDate.startOfDay(Date())
        let tomorrow = RuDate.addDays(today, 1)
        if RuDate.isoString(from: date) == RuDate.isoString(from: today) {
            addDateMode = 0
        } else if RuDate.isoString(from: date) == RuDate.isoString(from: tomorrow) {
            addDateMode = 1
        } else {
            addDateMode = 2
        }

        if let time = task.time, !time.isEmpty {
            showTimePicker = true
            let parts = time.split(separator: ":").compactMap { Int($0) }
            if parts.count == 2 {
                var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: Date())
                comps.hour = parts[0]
                comps.minute = parts[1]
                timeDate = RuDate.calendar.date(from: comps) ?? Date()
            }
        } else {
            showTimePicker = false
        }

        newDuration = task.duration
        showDurationPicker = task.duration > 0
        reminderEnabled = task.reminderEnabled && showTimePicker
        notificationPermissionMessage = nil
        calendarSyncEnabled = task.calendarSyncEnabled && showTimePicker
        calendarPermissionMessage = nil
        showAddTask = true
    }

    // MARK: - Подтвердить (создать / обновить)

    func commitAddTask() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let timeStr: String? = showTimePicker
            ? String(format: "%02d:%02d",
                     RuDate.calendar.component(.hour, from: timeDate),
                     RuDate.calendar.component(.minute, from: timeDate))
            : nil

        let shouldRemind = showTimePicker && reminderEnabled
        let shouldSyncCalendar = showTimePicker && calendarSyncEnabled
        if let task = editingTask {
            if task.isInbox {
                _ = repository.updateInboxTitle(task, title: title)
            } else {
                if let updated = repository.update(
                    task,
                    title: title,
                    date: newDate,
                    time: timeStr,
                    duration: newDuration,
                    reminderEnabled: shouldRemind,
                    calendarSyncEnabled: shouldSyncCalendar
                ) {
                    syncSideEffects(for: updated)
                }
            }
        } else {
            let created = repository.addScheduledTask(
                title: title,
                date: newDate,
                time: timeStr,
                duration: newDuration,
                reminderEnabled: shouldRemind,
                calendarSyncEnabled: shouldSyncCalendar
            )
            syncSideEffects(for: created)
        }
        reset()
    }

    // MARK: - Сбросить форму

    func reset() {
        showAddTask = false
        editingTask = nil
        newTitle = ""
        showTimePicker = false
        showDurationPicker = false
        addDateMode = 0
        newDuration = 0
        newDate = RuDate.startOfDay(Date())
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
    }
}
