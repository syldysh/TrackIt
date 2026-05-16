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
    let notificationService: any NotificationServiceProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Форм-стейт

    @Published var newText = ""
    @Published var showAddModal = false
    let taskEditorVM: AddTaskViewModel

    // MARK: - Вычисляемые свойства

    var inboxTasks: [Task] { repository.inboxTasks }

    var canAdd: Bool {
        !newText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        repository: any TaskRepositoryProtocol,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService
        self.taskEditorVM = AddTaskViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )
        repository.changePublisher
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        taskEditorVM.objectWillChange
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

    func toggle(_ task: Task) {
        guard let updated = repository.toggle(task) else { return }
        syncSideEffects(for: updated)
    }

    func delete(_ task: Task) {
        calendarSyncService.deleteEvent(for: task)
        notificationService.cancelNotification(for: task.id)
        repository.delete(task)
    }

    func scheduleFromInbox(
        _ task: Task,
        date: Date,
        time: String?,
        duration: Int16,
        reminderEnabled: Bool,
        calendarSyncEnabled: Bool
    ) {
        guard let updated = repository.scheduleFromInbox(
            task,
            date: date,
            time: time,
            duration: duration,
            reminderEnabled: reminderEnabled,
            calendarSyncEnabled: calendarSyncEnabled
        ) else { return }
        syncSideEffects(for: updated)
    }

    private func syncSideEffects(for task: Task) {
        notificationService.syncNotification(for: task)
        calendarSyncService.syncEvent(for: task) { [weak self] eventIdentifier in
            guard task.calendarEventIdentifier != eventIdentifier else { return }
            _ = self?.repository.updateCalendarEventIdentifier(eventIdentifier, for: task.id)
        }
    }
}
