//
//  PersistenceController.swift
//  TrackIt
//
//  Точка инициализации CoreData-стека.
//  Единственное место в проекте, которое знает про NSPersistentContainer.
//

import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TrackIt")

        if inMemory {
            // Для тестов и превью — данные хранятся только в памяти
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData: не удалось загрузить хранилище — \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

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
