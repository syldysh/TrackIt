//
//  SchedulePickerViewModel.swift
//  TrackIt
//
//  ViewModel формы выбора даты и времени в режиме планирования.
//  Хранит состояние формы и проверяет разрешения для уведомлений и календаря.
//

import Foundation
import Combine

final class SchedulePickerViewModel: ObservableObject {
    @Published var schedDate: Date? = RuDate.startOfDay(Date())
    @Published var nativeDateSelection = RuDate.startOfDay(Date())
    @Published var displayedMonth = RuDate.startOfMonth(Date())
    @Published var showTimePicker = false
    @Published var timeDate = Date()
    @Published var selectedDuration: Int16 = 0
    @Published var showDurationPicker = false
    @Published var reminderEnabled = false
    @Published var notificationPermissionMessage: String? = nil
    @Published var calendarSyncEnabled = false
    @Published var calendarPermissionMessage: String? = nil

    private let notificationService: any NotificationServiceProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private var preferredDay = RuDate.calendar.component(.day, from: Date())

    init(
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService
    }

    var today: Date { RuDate.startOfDay(Date()) }

    var shouldShowTodayButton: Bool {
        !Calendar.current.isDateInToday(nativeDateSelection)
    }

    var canGoToPreviousMonth: Bool {
        let currentMonth = RuDate.startOfMonth(Date())
        return displayedMonth > currentMonth
    }

    var canShowReminderToggle: Bool {
        showTimePicker
    }

    var canShowCalendarSyncToggle: Bool {
        showTimePicker
    }

    var timeString: String? {
        guard showTimePicker else { return nil }
        return String(
            format: "%02d:%02d",
            RuDate.calendar.component(.hour, from: timeDate),
            RuDate.calendar.component(.minute, from: timeDate)
        )
    }

    var shouldScheduleReminder: Bool {
        showTimePicker && reminderEnabled
    }

    var shouldSyncCalendar: Bool {
        showTimePicker && calendarSyncEnabled
    }

    func updateDateSelection(_ value: Date) {
        let selectedDay = RuDate.startOfDay(value)
        setSelection(selectedDay, updatesPreferredDay: true)
    }

    func goToToday() {
        let today = RuDate.startOfDay(Date())
        setSelection(today, updatesPreferredDay: true)
    }

    func goToPreviousMonth() {
        guard canGoToPreviousMonth,
              let month = RuDate.calendar.date(byAdding: .month, value: -1, to: displayedMonth) else {
            return
        }
        moveToMonth(month)
    }

    func goToNextMonth() {
        guard let month = RuDate.calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        moveToMonth(month)
    }

    func selectDayInDisplayedMonth(_ day: Int) {
        guard let date = dateInDisplayedMonth(day: day), date >= today else { return }
        setSelection(date, updatesPreferredDay: true)
    }

    func dateInDisplayedMonth(day: Int) -> Date? {
        let year = RuDate.calendar.component(.year, from: displayedMonth)
        let month = RuDate.calendar.component(.month, from: displayedMonth)
        return RuDate.calendar.date(from: DateComponents(year: year, month: month, day: day))
            .map(RuDate.startOfDay)
    }

    private func moveToMonth(_ month: Date) {
        displayedMonth = RuDate.startOfMonth(month)

        let monthIndex = RuDate.calendar.component(.month, from: displayedMonth) - 1
        let year = RuDate.calendar.component(.year, from: displayedMonth)
        let day = min(preferredDay, RuDate.daysInMonth(year: year, month: monthIndex))
        guard let preservedDate = dateInDisplayedMonth(day: day) else { return }

        setSelection(max(preservedDate, today), updatesPreferredDay: false)
    }

    private func setSelection(_ date: Date, updatesPreferredDay: Bool) {
        let selectedDay = RuDate.startOfDay(date)
        nativeDateSelection = selectedDay
        schedDate = selectedDay
        displayedMonth = RuDate.startOfMonth(selectedDay)
        if updatesPreferredDay {
            preferredDay = RuDate.calendar.component(.day, from: selectedDay)
        }
    }

    func setReminderEnabled(_ enabled: Bool) {
        guard enabled else {
            disableReminder()
            return
        }

        guard showTimePicker else {
            disableReminder()
            return
        }

        notificationService.requestAuthorizationIfNeeded { [weak self] granted in
            guard let self else { return }
            self.reminderEnabled = granted
            self.notificationPermissionMessage = granted ? nil : Self.permissionDeniedText
        }
    }

    func disableReminder() {
        reminderEnabled = false
        notificationPermissionMessage = nil
    }

    func setCalendarSyncEnabled(_ enabled: Bool) {
        guard enabled else {
            disableCalendarSync()
            return
        }

        guard showTimePicker else {
            disableCalendarSync()
            return
        }

        calendarSyncService.requestAuthorizationIfNeeded { [weak self] granted in
            guard let self else { return }
            self.calendarSyncEnabled = granted
            self.calendarPermissionMessage = granted ? nil : Self.calendarPermissionDeniedText
        }
    }

    func disableCalendarSync() {
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
    }

    private static let permissionDeniedText = "Разрешение не выдано. Включите уведомления для TrackIt в настройках iOS."
    private static let calendarPermissionDeniedText = "Разрешение не выдано. Включите доступ к календарям для TrackIt в настройках iOS."
}
