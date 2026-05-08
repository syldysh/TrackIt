//
//  AddTaskViewModel+SideEffects.swift
//  TrackIt
//
//  Разрешения и синхронизация внешних side effects формы задачи.
//

import Foundation

extension AddTaskViewModel {
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
            reminderEnabled = granted
            notificationPermissionMessage = granted ? nil : Self.permissionDeniedText
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
            calendarSyncEnabled = granted
            calendarPermissionMessage = granted ? nil : Self.calendarPermissionDeniedText
        }
    }

    func disableCalendarSync() {
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
    }

    func syncSideEffects(for task: Task) {
        notificationService.syncNotification(for: task)
        calendarSyncService.syncEvent(for: task) { [weak self] eventIdentifier in
            guard task.calendarEventIdentifier != eventIdentifier else { return }
            _ = self?.repository.updateCalendarEventIdentifier(eventIdentifier, for: task.id)
        }
    }

    private static let permissionDeniedText = "Разрешение не выдано. Включите уведомления для TrackIt в настройках iOS."
    private static let calendarPermissionDeniedText = "Разрешение не выдано. Включите доступ к календарям для TrackIt в настройках iOS."
}
