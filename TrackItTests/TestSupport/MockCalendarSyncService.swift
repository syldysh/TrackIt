@testable import TrackIt

final class MockCalendarSyncService: CalendarSyncServiceProtocol {
    var authorizationResult = true
    var requestAuthorizationCalls = 0
    var syncedTasks: [Task] = []
    var deletedTasks: [Task] = []
    var syncedEventIdentifier: String?

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        requestAuthorizationCalls += 1
        completion(authorizationResult)
    }

    func syncEvent(for task: Task, completion: @escaping (String?) -> Void) {
        syncedTasks.append(task)
        completion(syncedEventIdentifier)
    }

    func deleteEvent(for task: Task) {
        deletedTasks.append(task)
    }
}
