//
//  ProgressAnalyticsDelta.swift
//  TrackIt
//
//  Описывает улучшившиеся метрики прогресса между двумя снимками статистики.
//

import Foundation

enum ProgressAnalyticsField: Hashable {
    case completionRate
    case completedCount
    case streakDays
}

struct ProgressAnalyticsDelta: Identifiable, Equatable {
    let id = UUID()
    let didImproveCompletionRate: Bool
    let didImproveCompletedCount: Bool
    let didImproveStreak: Bool

    init(previous: StatisticsSnapshot, current: StatisticsSnapshot) {
        didImproveCompletionRate = current.progress.completionRate > previous.progress.completionRate
        didImproveCompletedCount = current.progress.completedCount > previous.progress.completedCount
        didImproveStreak = current.streak.days > previous.streak.days
    }

    var improvedFields: Set<ProgressAnalyticsField> {
        var fields = Set<ProgressAnalyticsField>()
        if didImproveCompletionRate { fields.insert(.completionRate) }
        if didImproveCompletedCount { fields.insert(.completedCount) }
        if didImproveStreak { fields.insert(.streakDays) }
        return fields
    }

    var hasPositiveChanges: Bool {
        !improvedFields.isEmpty
    }
}
