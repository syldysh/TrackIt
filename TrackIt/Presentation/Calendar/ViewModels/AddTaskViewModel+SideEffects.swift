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

        PermissionRequestHelper.requestNotification(
            service: notificationService,
            requiresTimePicker: showTimePicker
        ) { [weak self] enabled, message in
            guard let self else { return }
            reminderEnabled = enabled
            notificationPermissionMessage = message
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

        PermissionRequestHelper.requestCalendarAccess(
            service: calendarSyncService,
            requiresTimePicker: showTimePicker
        ) { [weak self] enabled, message in
            guard let self else { return }
            calendarSyncEnabled = enabled
            calendarPermissionMessage = message
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
}
