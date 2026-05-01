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

    var completedCount: Int { repository.completedCount }

    var streakDays: Int {
        StatisticsService.streakDays(tasks: repository.tasks)
    }

    var completionRate: Int {
        StatisticsService.completionRate(tasks: repository.tasks)
    }

    func weeklyActivity() -> [Int] {
        StatisticsService.weeklyActivity(tasks: repository.tasks)
    }

    var completedTasks: [Task] {
        StatisticsService.completedTasks(tasks: repository.tasks)
    }

    var streakSupportText: String {
        streakDays > 0 ? "Молодец! Продолжай дальше 🔥" : "Начните серию сегодня — это хороший момент"
    }
}
