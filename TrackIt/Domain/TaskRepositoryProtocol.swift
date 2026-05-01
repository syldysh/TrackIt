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

    // Keeps the protocol usable as `any TaskRepositoryProtocol` without ObservableObject associated types.
    var changePublisher: AnyPublisher<Void, Never> { get }

    func tasks(for date: Date) -> [Task]

    @discardableResult func addInboxTask(title: String) -> Task
    @discardableResult func addScheduledTask(title: String, date: Date, time: String?, duration: Int16, reminderEnabled: Bool, calendarSyncEnabled: Bool) -> Task

    @discardableResult func toggle(_ task: Task) -> Task?
    func pin(_ task: Task)
    func delete(_ task: Task)
    @discardableResult func setTime(_ time: String?, for task: Task) -> Task?
    @discardableResult func scheduleFromInbox(_ task: Task, date: Date, time: String?, duration: Int16, reminderEnabled: Bool, calendarSyncEnabled: Bool) -> Task?
    @discardableResult func update(_ task: Task, title: String, date: Date, time: String?, duration: Int16, reminderEnabled: Bool, calendarSyncEnabled: Bool) -> Task?
    @discardableResult func updateCalendarEventIdentifier(_ identifier: String?, for taskID: UUID) -> Task?
}
