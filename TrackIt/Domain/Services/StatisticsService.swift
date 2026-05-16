//
//  StatisticsService.swift
//  TrackIt
//
//  Бизнес-логика статистики — вынесена из TaskRepository.
//  Принимает [Task], не зависит от CoreData.
//

import Foundation

struct StatisticsDailySummary: Identifiable, Equatable {
    let date: Date
    let completedCount: Int
    let totalCount: Int

    var id: Date { date }

    var completionRate: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount) * 100).rounded())
    }
}

struct StatisticsProgressSummary: Equatable {
    let startDate: Date
    let endDate: Date
    let completedCount: Int
    let totalCount: Int

    var completionRate: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount) * 100).rounded())
    }
}

struct StatisticsStreakSummary: Equatable {
    let days: Int
    let countedThrough: Date?
    let recentDays: [StatisticsDailySummary]
}

struct StatisticsSnapshot: Equatable {
    let progress: StatisticsProgressSummary
    let completedTasks: [Task]
    let streak: StatisticsStreakSummary
    let trendDays: [StatisticsDailySummary]
    let bestProductivityDay: StatisticsDailySummary?
}

enum StatisticsService {

    static func snapshot(tasks: [Task], referenceDate: Date = Date()) -> StatisticsSnapshot {
        let days = currentWeekDays(containing: referenceDate)
        let startDate = days.first ?? RuDate.startOfDay(referenceDate)
        let endDate = days.last ?? startDate
        let trendDays = days.map { dailySummary(for: $0, tasks: tasks) }
        let completedTasks = completedTasks(tasks: tasks, from: startDate, through: endDate)
        let progress = StatisticsProgressSummary(
            startDate: startDate,
            endDate: endDate,
            completedCount: completedTasks.count,
            totalCount: trendDays.reduce(0) { $0 + $1.totalCount }
        )
        return StatisticsSnapshot(
            progress: progress,
            completedTasks: completedTasks,
            streak: streakSummary(tasks: tasks, recentDays: trendDays, referenceDate: referenceDate),
            trendDays: trendDays,
            bestProductivityDay: bestProductivityDay(from: trendDays)
        )
    }

    static func completionRate(tasks: [Task]) -> Int {
        snapshot(tasks: tasks).progress.completionRate
    }

    static func streakDays(tasks: [Task]) -> Int {
        snapshot(tasks: tasks).streak.days
    }

    static func weeklyActivity(tasks: [Task]) -> [Int] {
        snapshot(tasks: tasks).trendDays.map(\.completedCount)
    }

    static func completedTasks(tasks: [Task]) -> [Task] {
        let snapshot = snapshot(tasks: tasks)
        return completedTasks(tasks: tasks, from: snapshot.progress.startDate, through: snapshot.progress.endDate)
    }

    private static func currentWeekDays(containing referenceDate: Date) -> [Date] {
        let weekStart = RuDate.weekStart(for: referenceDate)
        return (0..<7).compactMap { offset in
            RuDate.calendar.date(byAdding: .day, value: offset, to: weekStart)
                .map(RuDate.startOfDay)
        }
    }

    private static func dailySummary(for day: Date, tasks: [Task]) -> StatisticsDailySummary {
        let dayTasks = scheduledTasks(tasks, on: day)
        return StatisticsDailySummary(
            date: day,
            completedCount: dayTasks.filter(\.isCompleted).count,
            totalCount: dayTasks.count
        )
    }

    private static func streakSummary(
        tasks: [Task],
        recentDays: [StatisticsDailySummary],
        referenceDate: Date
    ) -> StatisticsStreakSummary {
        let today = RuDate.startOfDay(referenceDate)
        let yesterday = RuDate.addDays(today, -1)
        // Если сегодня ещё нет выполненной задачи, сохраняем активную серию до вчера.
        let firstCountedDay = hasCompletedTask(on: today, tasks: tasks) ? today : yesterday

        guard hasCompletedTask(on: firstCountedDay, tasks: tasks) else {
            return StatisticsStreakSummary(days: 0, countedThrough: nil, recentDays: recentDays)
        }

        var count = 0
        var day = firstCountedDay
        while hasCompletedTask(on: day, tasks: tasks) {
            count += 1
            day = RuDate.addDays(day, -1)
        }

        return StatisticsStreakSummary(days: count, countedThrough: firstCountedDay, recentDays: recentDays)
    }

    private static func bestProductivityDay(from days: [StatisticsDailySummary]) -> StatisticsDailySummary? {
        days
            .filter { $0.totalCount > 0 }
            .max { lhs, rhs in
                if lhs.completionRate != rhs.completionRate {
                    return lhs.completionRate < rhs.completionRate
                }
                if lhs.completedCount != rhs.completedCount {
                    return lhs.completedCount < rhs.completedCount
                }
                return lhs.date < rhs.date
            }
    }

    private static func completedTasks(tasks: [Task], from startDate: Date, through endDate: Date) -> [Task] {
        tasks
            .filter { task in
                guard !task.isInbox, task.isCompleted, let scheduled = task.dateScheduled else { return false }
                return isDate(scheduled, between: startDate, and: endDate)
            }
            .sorted {
                guard let lhsDate = $0.dateScheduled, let rhsDate = $1.dateScheduled else {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                if !RuDate.calendar.isDate(lhsDate, inSameDayAs: rhsDate) { return lhsDate > rhsDate }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
    }

    private static func scheduledTasks(_ tasks: [Task], on day: Date) -> [Task] {
        tasks.filter { task in
            guard !task.isInbox, let scheduled = task.dateScheduled else { return false }
            return RuDate.calendar.isDate(scheduled, inSameDayAs: day)
        }
    }

    private static func hasCompletedTask(on day: Date, tasks: [Task]) -> Bool {
        scheduledTasks(tasks, on: day).contains { $0.isCompleted }
    }

    private static func isDate(_ date: Date, between startDate: Date, and endDate: Date) -> Bool {
        let day = RuDate.startOfDay(date)
        return day >= startDate && day <= endDate
    }
}
