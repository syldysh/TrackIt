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

    // MARK: - Метрики

    var completedCount: Int { repository.completedCount }
    var totalScheduled: Int { repository.totalScheduled }

    var streakDays: Int {
        StatisticsService.streakDays(tasks: repository.tasks)
    }

    var completionRate: Int {
        StatisticsService.completionRate(tasks: repository.tasks)
    }

    func weeklyActivity() -> [Int] {
        StatisticsService.weeklyActivity(tasks: repository.tasks)
    }
}
