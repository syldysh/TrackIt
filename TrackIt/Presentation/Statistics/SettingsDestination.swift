//
//  SettingsDestination.swift
//  TrackIt
//
//  Описание разделов настроек.
//  Хранит название, иконку и текст заглушки для экранов настроек.
//

import SwiftUI

enum SettingsDestination: Identifiable {
    case notifications
    case help
    case privacy
    case about

    var id: String { title }

    var title: String {
        switch self {
        case .notifications: "Уведомления"
        case .help: "Помощь и обратная связь"
        case .privacy: "Политика конфиденциальности"
        case .about: "О приложении"
        }
    }

    var icon: String {
        switch self {
        case .notifications: "bell.fill"
        case .help: "questionmark.circle.fill"
        case .privacy: "lock.shield.fill"
        case .about: "info.circle.fill"
        }
    }

    var placeholderText: String {
        switch self {
        case .notifications:
            "Здесь позже появятся настройки уведомлений TrackIt."
        case .help:
            "Здесь позже появятся помощь, ответы на вопросы и форма обратной связи."
        case .privacy:
            "Здесь позже появится политика конфиденциальности приложения."
        case .about:
            "Здесь позже появится информация о версии и приложении TrackIt."
        }
    }
}
