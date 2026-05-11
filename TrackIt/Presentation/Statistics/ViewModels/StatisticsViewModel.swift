//
//  StatisticsViewModel.swift
//  TrackIt
//
//  ViewModel экрана «Прогресс».
//  Отдаёт статистические метрики; бизнес-логика — в StatisticsService.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {

    // MARK: - Зависимости

    private let repository: any TaskRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(repository: any TaskRepositoryProtocol) {
        self.repository = repository
        repository.changePublisher
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var statistics: StatisticsSnapshot {
        StatisticsService.snapshot(tasks: repository.tasks)
    }

    var completedCount: Int {
        statistics.progress.completedCount
    }

    var streakDays: Int {
        statistics.streak.days
    }

    var completionRate: Int {
        statistics.progress.completionRate
    }

    var periodTitle: String {
        "За последние 7 дней"
    }

    var progressSupportText: String {
        let progress = statistics.progress
        guard progress.totalCount > 0 else { return "Запланируйте задачу, чтобы увидеть прогресс." }
        if progress.completionRate >= 80 { return "Хороший темп! Большая часть задач закрыта." }
        if progress.completionRate >= 50 { return "Хороший прогресс за неделю." }
        return "Начните выполнять задачи, и прогресс будет расти."
    }

    func weeklyActivity() -> [Int] {
        statistics.trendDays.map(\.completedCount)
    }

    var completedTasks: [Task] {
        statistics.completedTasks
    }

    var streakSupportText: String {
        streakDays > 0 ? "Страйк держится! Выполняйте задачи, чтобы не потерять его." : "Выполните задачу на сегодня, чтобы начать страйк."
    }

    var trendDays: [StatisticsDailySummary] {
        statistics.trendDays
    }

    var bestProductivityDay: StatisticsDailySummary? {
        statistics.bestProductivityDay
    }
}
