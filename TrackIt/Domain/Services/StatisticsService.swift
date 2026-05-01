//
//  StatisticsService.swift
//  TrackIt
//
//  Бизнес-логика статистики — вынесена из TaskRepository.
//  Принимает [Task], не зависит от CoreData.
//

import Foundation

enum StatisticsService {

    // Процент выполнения запланированных задач
    static func completionRate(tasks: [Task]) -> Int {
        let scheduled = tasks.filter { !$0.isInbox }
        guard !scheduled.isEmpty else { return 0 }
        return Int(Double(scheduled.filter { $0.isCompleted }.count) / Double(scheduled.count) * 100)
    }

    // Серия дней подряд, в которые все запланированные задачи были выполнены
    static func streakDays(tasks: [Task]) -> Int {
        let calendar = RuDate.calendar
        var streak = 0
        var day = RuDate.startOfDay(Date())
        while true {
            let dayTasks = tasks.filter { task in
                guard !task.isInbox, let scheduled = task.dateScheduled else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            guard !dayTasks.isEmpty, dayTasks.allSatisfy({ $0.isCompleted }) else { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    // Количество выполненных задач по дням текущей недели (Пн–Вс)
    static func weeklyActivity(tasks: [Task]) -> [Int] {
        let calendar = RuDate.calendar
        let monday = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else { return 0 }
            return tasks.filter { task in
                guard task.isCompleted, let scheduled = task.dateScheduled else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }.count
        }
    }

    static func completedTasks(tasks: [Task]) -> [Task] {
        tasks
            .filter { $0.isCompleted }
            .sorted {
                let lhsDate = $0.dateScheduled ?? .distantPast
                let rhsDate = $1.dateScheduled ?? .distantPast
                if lhsDate != rhsDate { return lhsDate > rhsDate }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
    }
}
