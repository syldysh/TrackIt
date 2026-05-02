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
    @Published var nativeDateSelection = Date()
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

    init(
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService
    }

    var today: Date { RuDate.startOfDay(Date()) }

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
        schedDate = RuDate.startOfDay(value)
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
