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
    case about

    var id: String { title }

    var title: String {
        switch self {
        case .notifications: "Уведомления"
        case .help: "Помощь и обратная связь"
        case .about: "О приложении"
        }
    }

    var icon: String {
        switch self {
        case .notifications: "bell.fill"
        case .help: "questionmark.circle.fill"
        case .about: "info.circle.fill"
        }
    }

    var placeholderText: String {
        switch self {
        case .notifications:
            "Здесь позже появятся настройки уведомлений TrackIt."
        case .help:
            "Здесь позже появятся помощь, ответы на вопросы и форма обратной связи."
        case .about:
            "Здесь позже появится информация о версии и приложении TrackIt."
        }
    }
}
