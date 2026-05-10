//
//  StatisticsDetailDestination.swift
//  TrackIt
//
//  Тип подробной карточки статистики, открытой в bottom sheet.
//

import SwiftUI

enum StatisticsDetailDestination: Identifiable {
    case progress
    case completedTasks
    case streak
    case productivityTrend

    var id: String {
        switch self {
        case .progress: return "progress"
        case .completedTasks: return "completedTasks"
        case .streak: return "streak"
        case .productivityTrend: return "productivityTrend"
        }
    }

    var title: String {
        switch self {
        case .progress: return "Общий прогресс"
        case .completedTasks: return "Выполненные задачи"
        case .streak: return "Дней подряд"
        case .productivityTrend: return "Тренд продуктивности"
        }
    }

    var icon: String {
        switch self {
        case .progress: return "target"
        case .completedTasks: return "checkmark.circle.fill"
        case .streak: return "flame.fill"
        case .productivityTrend: return "chart.bar.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .progress: return .brandAccent
        case .completedTasks: return .brandGreen
        case .streak: return .brandOrange
        case .productivityTrend: return .brandPurple
        }
    }
}
