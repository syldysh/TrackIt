//
//  NotificationPermissionService.swift
//  TrackIt
//
//  Маленький сервис для чтения и запроса статуса разрешений уведомлений iOS.
//

import Foundation
import UserNotifications
import UIKit

enum NotificationPermissionStatus {
    case authorized
    case provisional
    case ephemeral
    case denied
    case notDetermined
    case unknown

    var allowsNotifications: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral: true
        case .denied, .notDetermined, .unknown: false
        }
    }
}

protocol NotificationPermissionServiceProtocol: AnyObject {
    func currentStatus(completion: @escaping (NotificationPermissionStatus) -> Void)
    func requestAuthorization(completion: @escaping (NotificationPermissionStatus) -> Void)
    func openAppSettings()
}

final class NotificationPermissionService: NotificationPermissionServiceProtocol {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func currentStatus(completion: @escaping (NotificationPermissionStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(Self.status(from: settings.authorizationStatus))
            }
        }
    }

    func requestAuthorization(completion: @escaping (NotificationPermissionStatus) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            self?.currentStatus(completion: completion)
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }

    private static func status(from status: UNAuthorizationStatus) -> NotificationPermissionStatus {
        switch status {
        case .authorized: .authorized
        case .provisional: .provisional
        case .ephemeral: .ephemeral
        case .denied: .denied
        case .notDetermined: .notDetermined
        @unknown default: .unknown
        }
    }
}
