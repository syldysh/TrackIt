//
//  TaskRepositoryProtocol.swift
//  TrackIt
//
//  Протокол репозитория задач. ViewModels зависят только от этого протокола,
//  а не от конкретного TaskRepository — это позволяет подменять реализацию
//  (мок для тестов, другое хранилище) без изменения логики презентации.
//

import Foundation
import Combine

protocol TaskRepositoryProtocol: AnyObject {
    var tasks: [Task] { get }
    var inboxTasks: [Task] { get }
    var scheduledTasks: [Task] { get }
    var completedCount: Int { get }
    var totalScheduled: Int { get }

    // Публикатор «состояние задач изменилось» — для подписки ViewModel-ов.
    // Отдельный publisher, а не ObservableObject, чтобы у протокола не было
    // associatedtype и его можно было использовать как `any TaskRepositoryProtocol`.
    var changePublisher: AnyPublisher<Void, Never> { get }

    func tasks(for date: Date) -> [Task]

    @discardableResult func addInboxTask(title: String) -> Task
    @discardableResult func addScheduledTask(title: String, date: Date, time: String?, duration: Int16) -> Task

    func toggle(_ task: Task)
    func pin(_ task: Task)
    func delete(_ task: Task)
    func setTime(_ time: String?, for task: Task)
    func scheduleFromInbox(_ task: Task, date: Date, time: String?, duration: Int16)
    func update(_ task: Task, title: String, date: Date, time: String?, duration: Int16)
}
