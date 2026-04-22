//
//  InboxViewModel.swift
//  TrackIt
//
//  ViewModel для экрана «Планировщик».
//  Содержит реальную логику: валидацию ввода, trimming, canAdd.
//

import Foundation
import Combine

final class InboxViewModel: ObservableObject {

    // MARK: - Зависимости

    private let repository: any TaskRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Форм-стейт

    @Published var newText = ""
    @Published var showAddModal = false

    // MARK: - Вычисляемые свойства

    var inboxTasks: [Task] { repository.inboxTasks }

    var canAdd: Bool {
        !newText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Init

    init(repository: any TaskRepositoryProtocol) {
        self.repository = repository
        repository.changePublisher
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Действия

    func commitTask() {
        let text = newText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        repository.addInboxTask(title: text)
        newText = ""
        showAddModal = false
    }

    func toggle(_ task: Task) { repository.toggle(task) }
    func pin(_ task: Task)    { repository.pin(task) }
    func delete(_ task: Task) { repository.delete(task) }

    func scheduleFromInbox(_ task: Task, date: Date, time: String?, duration: Int16) {
        repository.scheduleFromInbox(task, date: date, time: time, duration: duration)
    }
}
