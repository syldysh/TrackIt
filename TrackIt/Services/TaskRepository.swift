//
//  TaskRepository.swift
//  TrackIt
//
//  Единственное место, где живёт NSManagedObject.
//  Наружу отдаёт только [Task] — domain-модели без CoreData.
//

import Foundation
import CoreData
import Combine

final class TaskRepository: ObservableObject, TaskRepositoryProtocol {

    // MARK: - Публичное состояние (domain-модели, без NSManagedObject)

    @Published var tasks: [Task] = []

    // Публикатор изменений для VM — абстракция над objectWillChange.
    // VM подписываются на него, не зная про ObservableObject.
    var changePublisher: AnyPublisher<Void, Never> {
        objectWillChange.map { _ in () }.eraseToAnyPublisher()
    }

    // MARK: - Приватные зависимости

    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    private var taskItems: [TaskItem] = []

    // MARK: - Init

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.context = persistenceController.viewContext
        fetchAll()
    }

    // MARK: - Маппинг (только внутри Repository)

    private func map(_ item: TaskItem) -> Task {
        Task(
            id: item.id ?? UUID(),
            title: item.title ?? "",
            isCompleted: item.isCompleted,
            isInbox: item.isInbox,
            pinned: item.pinned,
            dateScheduled: item.dateScheduled,
            time: item.time,
            duration: item.duration
        )
    }

    private func item(for task: Task) -> TaskItem? {
        taskItems.first { $0.id == task.id }
    }

    // MARK: - Fetch

    func fetchAll() {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskItem.pinned, ascending: false),
            NSSortDescriptor(keyPath: \TaskItem.dateScheduled, ascending: true)
        ]
        taskItems = (try? context.fetch(request)) ?? []
        tasks = taskItems.map(map)
    }

    // MARK: - Вычисляемые свойства

    var inboxTasks: [Task] {
        tasks.filter { $0.isInbox }
    }

    var scheduledTasks: [Task] {
        tasks.filter { !$0.isInbox }
    }

    func tasks(for date: Date) -> [Task] {
        let calendar = Calendar.current
        return scheduledTasks.filter { task in
            guard let scheduled = task.dateScheduled else { return false }
            return calendar.isDate(scheduled, inSameDayAs: date)
        }
    }

    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }

    var totalScheduled: Int {
        scheduledTasks.count
    }

    // MARK: - Создание

    @discardableResult
    func addInboxTask(title: String) -> Task {
        let item = TaskItem(context: context)
        item.id = UUID()
        item.title = title
        item.isCompleted = false
        item.isInbox = true
        item.pinned = false
        save()
        return map(item)
    }

    @discardableResult
    func addScheduledTask(title: String, date: Date, time: String? = nil, duration: Int16 = 0) -> Task {
        let item = TaskItem(context: context)
        item.id = UUID()
        item.title = title
        item.isCompleted = false
        item.isInbox = false
        item.pinned = false
        item.dateScheduled = date
        item.time = time
        item.duration = duration
        save()
        return map(item)
    }

    // MARK: - Обновление

    func scheduleFromInbox(_ task: Task, date: Date, time: String? = nil, duration: Int16 = 0) {
        guard let item = item(for: task) else { return }
        item.isInbox = false
        item.dateScheduled = date
        item.time = time
        item.duration = duration
        save()
    }

    func update(_ task: Task, title: String, date: Date, time: String?, duration: Int16) {
        guard let item = item(for: task) else { return }
        item.title = title
        item.dateScheduled = date
        item.time = time
        item.duration = duration
        item.isInbox = false
        save()
    }

    func toggle(_ task: Task) {
        guard let item = item(for: task) else { return }
        item.isCompleted.toggle()
        save()
    }

    func pin(_ task: Task) {
        guard let item = item(for: task) else { return }
        item.pinned.toggle()
        save()
    }

    func setTime(_ time: String?, for task: Task) {
        guard let item = item(for: task) else { return }
        item.time = time
        save()
    }

    // MARK: - Удаление

    func delete(_ task: Task) {
        guard let item = item(for: task) else { return }
        context.delete(item)
        save()
    }

    // MARK: - Приватные методы

    private func save() {
        persistenceController.save()
        fetchAll()
    }
}
