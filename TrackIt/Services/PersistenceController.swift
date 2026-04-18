//
//  PersistenceController.swift
//  TrackIt
//
//  Точка инициализации CoreData-стека.
//  Единственное место в проекте, которое знает про NSPersistentContainer.
//

import CoreData

struct PersistenceController {

    // MARK: - Singleton

    // Единственный экземпляр контроллера на всё приложение
    static let shared = PersistenceController()

    // MARK: - Контейнер

    let container: NSPersistentContainer

    // Основной контекст для работы с UI-потоком
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Инициализация

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TrackIt")

        if inMemory {
            // Для тестов и превью — данные хранятся только в памяти
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData: не удалось загрузить хранилище — \(error), \(error.userInfo)")
            }
        }

        // Автоматически мержим изменения из фоновых контекстов
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Сохранение

    // Сохраняет контекст, если есть несохранённые изменения
    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("CoreData: ошибка сохранения — \(nserror), \(nserror.userInfo)")
        }
    }
}
