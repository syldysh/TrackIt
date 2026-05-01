import Foundation
import UserNotifications

protocol NotificationServiceProtocol: AnyObject {
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void)
    func syncNotification(for task: Task)
    func cancelNotification(for taskID: UUID)
}

final class LocalNotificationManager: NotificationServiceProtocol {
    static let shared = LocalNotificationManager()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            guard let self else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    func syncNotification(for task: Task) {
        let id = notificationIdentifier(for: task.id)
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])

        guard task.reminderEnabled,
              !task.isCompleted,
              let fireDate = notificationDate(for: task),
              fireDate > Date() else {
            return
        }

        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional ||
                  settings.authorizationStatus == .ephemeral else {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "TrackIt"
            content.body = task.title
            content.sound = .default
            content.userInfo = ["taskID": task.id.uuidString]

            let components = RuDate.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancelNotification(for taskID: UUID) {
        let id = notificationIdentifier(for: taskID)
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }

    private func notificationIdentifier(for taskID: UUID) -> String {
        "task-reminder-\(taskID.uuidString)"
    }

    private func notificationDate(for task: Task) -> Date? {
        guard let date = task.dateScheduled,
              let time = task.time,
              !time.isEmpty else { return nil }

        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }

        var components = RuDate.calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = parts[0]
        components.minute = parts[1]
        return RuDate.calendar.date(from: components)
    }
}
