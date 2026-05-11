//
//  SettingsDestination.swift
//  TrackIt
//
//  Описание разделов настроек.
//  Хранит название и иконку для строк настроек.
//

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
}
