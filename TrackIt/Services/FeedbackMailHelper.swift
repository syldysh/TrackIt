//
//  FeedbackMailHelper.swift
//  TrackIt
//
//  Формирует mailto-ссылку для обратной связи.
//

import Foundation
import UIKit

enum FeedbackMailHelper {
    static let recipient = "syldysshogzhal@gmail.com"

    static func makeFeedbackURL() -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Отзыв о TrackIt"),
            URLQueryItem(name: "body", value: feedbackBody)
        ]
        return components.url
    }

    private static var feedbackBody: String {
        """
        Здравствуйте!

        Хочу оставить отзыв о TrackIt:

        [Опишите ваш отзыв здесь]

        —
        Версия приложения: \(appVersion)
        Build: \(buildNumber)
        Устройство: \(UIDevice.current.model)
        iOS: \(UIDevice.current.systemVersion)
        """
    }

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Неизвестно"
    }

    private static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Неизвестно"
    }
}
