//
//  StatisticsDetailDestination.swift
//  TrackIt
//
//  Тип подробной карточки статистики, открытой в bottom sheet.
//

import SwiftUI

enum StatisticsDetailDestination: Identifiable, Equatable {
    case progress
    case completedTasks
    case streak
    case productivityTrend

    static let orderedCases: [StatisticsDetailDestination] = [
        .progress,
        .completedTasks,
        .streak,
        .productivityTrend
    ]

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

    var previous: StatisticsDetailDestination? {
        guard let index = Self.orderedCases.firstIndex(of: self), index > 0 else { return nil }
        return Self.orderedCases[index - 1]
    }

    var next: StatisticsDetailDestination? {
        guard let index = Self.orderedCases.firstIndex(of: self),
              index < Self.orderedCases.count - 1 else { return nil }
        return Self.orderedCases[index + 1]
    }
}
