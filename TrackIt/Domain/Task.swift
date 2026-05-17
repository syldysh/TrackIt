//
//  Task.swift
//  TrackIt
//
//  Domain-модель задачи. Чистый value type — не знает ничего про CoreData.
//  Единственное место, где TaskItem маппится в Task — TaskRepository.
//

import Foundation

struct Task: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var isInbox: Bool
    var pinned: Bool
    var dateScheduled: Date?
    var time: String?
    var duration: Int16
    var reminderEnabled: Bool
    var calendarSyncEnabled: Bool
    var calendarEventIdentifier: String?
}

extension Task {
    /// Порядок отображения в списке дня: закреплённые выше, затем задачи со временем, затем по времени.
    static func displayOrder(ascending lhs: Task, _ rhs: Task) -> Bool {
        if lhs.pinned != rhs.pinned { return lhs.pinned && !rhs.pinned }
        let t0 = lhs.time ?? "", t1 = rhs.time ?? ""
        if t0.isEmpty != t1.isEmpty { return !t0.isEmpty }
        return t0 < t1
    }
}
