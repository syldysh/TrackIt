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
    private let notificationService: any NotificationServiceProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var statistics: StatisticsSnapshot
    @Published private(set) var analyticsDelta: ProgressAnalyticsDelta?

    // MARK: - Init

    init(
        repository: any TaskRepositoryProtocol,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService
        self.statistics = StatisticsService.snapshot(tasks: repository.tasks)
        repository.changePublisher
            .sink { [weak self] _ in self?.refreshAnalytics() }
            .store(in: &cancellables)
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
        "За текущую неделю"
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

    func markTaskIncomplete(_ task: Task) {
        guard task.isCompleted, let updated = repository.toggle(task) else { return }
        syncSideEffects(for: updated)
    }

    func refreshAnalytics() {
        let previous = statistics
        let current = StatisticsService.snapshot(tasks: repository.tasks)
        statistics = current

        let delta = ProgressAnalyticsDelta(previous: previous, current: current)
        if delta.hasPositiveChanges {
            analyticsDelta = delta
        } else if previous != current {
            analyticsDelta = nil
        }
    }

    func consumeAnalyticsDelta(_ id: UUID) {
        guard analyticsDelta?.id == id else { return }
        analyticsDelta = nil
    }

    private func syncSideEffects(for task: Task) {
        notificationService.syncNotification(for: task)
        calendarSyncService.syncEvent(for: task) { [weak self] eventIdentifier in
            guard task.calendarEventIdentifier != eventIdentifier else { return }
            _ = self?.repository.updateCalendarEventIdentifier(eventIdentifier, for: task.id)
        }
    }
}
