//
//  StatisticsNotificationSettingsViewModel.swift
//  TrackIt
//
//  ViewModel экрана настроек уведомлений статистики.
//

import Foundation

final class StatisticsNotificationSettingsViewModel: ObservableObject {
    @Published private(set) var taskRemindersEnabled: Bool
    @Published private(set) var streakReminderEnabled: Bool
    @Published var permissionAlert: NotificationPermissionAlert?

    private let permissionService: any NotificationPermissionServiceProtocol
    private let defaults: UserDefaults

    private enum Setting {
        case taskReminders
        case streakReminder
    }

    private enum Key {
        static let taskReminders = "settings.taskRemindersEnabled"
        static let streakReminder = "settings.streakReminderEnabled"
    }

    init(
        permissionService: any NotificationPermissionServiceProtocol = NotificationPermissionService(),
        defaults: UserDefaults = .standard
    ) {
        self.permissionService = permissionService
        self.defaults = defaults
        taskRemindersEnabled = defaults.object(forKey: Key.taskReminders) as? Bool ?? true
        streakReminderEnabled = defaults.object(forKey: Key.streakReminder) as? Bool ?? false
    }

    func setTaskRemindersEnabled(_ isEnabled: Bool) {
        update(.taskReminders, isEnabled: isEnabled)
    }

    func setStreakReminderEnabled(_ isEnabled: Bool) {
        update(.streakReminder, isEnabled: isEnabled)
    }

    func openAppSettings() {
        permissionService.openAppSettings()
    }

    private func update(_ setting: Setting, isEnabled: Bool) {
        guard isEnabled else {
            setStoredValue(false, for: setting)
            return
        }

        permissionService.currentStatus { [weak self] status in
            self?.enable(setting, with: status)
        }
    }

    private func enable(_ setting: Setting, with status: NotificationPermissionStatus) {
        switch status {
        case .notDetermined:
            permissionService.requestAuthorization { [weak self] status in
                self?.handleAuthorizationResult(status, for: setting)
            }
        case .denied:
            setStoredValue(false, for: setting)
            permissionAlert = .openSettings
        case .authorized, .provisional, .ephemeral:
            setStoredValue(true, for: setting)
        case .unknown:
            setStoredValue(false, for: setting)
            permissionAlert = .unknown
        }
    }

    private func handleAuthorizationResult(_ status: NotificationPermissionStatus, for setting: Setting) {
        if status.allowsNotifications {
            setStoredValue(true, for: setting)
        } else {
            setStoredValue(false, for: setting)
            permissionAlert = status == .denied ? .openSettings : .denied
        }
    }

    private func setStoredValue(_ value: Bool, for setting: Setting) {
        switch setting {
        case .taskReminders:
            taskRemindersEnabled = value
            defaults.set(value, forKey: Key.taskReminders)
        case .streakReminder:
            streakReminderEnabled = value
            defaults.set(value, forKey: Key.streakReminder)
        }
    }
}

struct NotificationPermissionAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let canOpenSettings: Bool

    static let denied = NotificationPermissionAlert(
        title: "Уведомления выключены",
        message: "TrackIt не сможет отправлять напоминания без разрешения iOS.",
        canOpenSettings: false
    )

    static let openSettings = NotificationPermissionAlert(
        title: "Уведомления запрещены",
        message: "Разрешение отключено в iOS. Откройте настройки приложения, чтобы включить уведомления.",
        canOpenSettings: true
    )

    static let unknown = NotificationPermissionAlert(
        title: "Не удалось проверить доступ",
        message: "Попробуйте включить уведомления ещё раз позже.",
        canOpenSettings: false
    )
}
