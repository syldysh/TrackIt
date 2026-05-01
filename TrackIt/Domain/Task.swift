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
