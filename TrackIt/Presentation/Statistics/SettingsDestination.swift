//
//  SettingsDestination.swift
//  TrackIt
//
//  Описание разделов настроек.
//  Хранит название и иконку, чтобы строки меню и модалки брали данные из одного места.
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
}
