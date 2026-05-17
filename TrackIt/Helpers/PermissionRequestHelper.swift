//
//  PermissionRequestHelper.swift
//  TrackIt
//
//  Общая логика запроса разрешений для форм задачи.
//

enum PermissionRequestHelper {
    static let notificationDeniedText = "Разрешение не выдано. Включите уведомления для TrackIt в настройках iOS."
    static let calendarDeniedText = "Разрешение не выдано. Включите доступ к календарям для TrackIt в настройках iOS."

    static func requestNotification(
        service: any NotificationServiceProtocol,
        requiresTimePicker: Bool,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard requiresTimePicker else {
            completion(false, nil)
            return
        }

        service.requestAuthorizationIfNeeded { granted in
            completion(granted, granted ? nil : notificationDeniedText)
        }
    }

    static func requestCalendarAccess(
        service: any CalendarSyncServiceProtocol,
        requiresTimePicker: Bool,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard requiresTimePicker else {
            completion(false, nil)
            return
        }

        service.requestAuthorizationIfNeeded { granted in
            completion(granted, granted ? nil : calendarDeniedText)
        }
    }
}
