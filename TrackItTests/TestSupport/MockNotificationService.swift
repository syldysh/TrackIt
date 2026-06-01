import Foundation
@testable import TrackIt

final class MockNotificationService: NotificationServiceProtocol {
    var authorizationResult = true
    var requestAuthorizationCalls = 0
    var syncedTasks: [Task] = []
    var cancelledTaskIDs: [UUID] = []

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        requestAuthorizationCalls += 1
        completion(authorizationResult)
    }

    func syncNotification(for task: Task) {
        syncedTasks.append(task)
    }

    func cancelNotification(for taskID: UUID) {
        cancelledTaskIDs.append(taskID)
    }
}
