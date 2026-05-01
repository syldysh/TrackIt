import Foundation
import EventKit

protocol CalendarSyncServiceProtocol: AnyObject {
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void)
    func syncEvent(for task: Task, completion: @escaping (String?) -> Void)
    func deleteEvent(for task: Task)
}

final class CalendarSyncService: CalendarSyncServiceProtocol {
    static let shared = CalendarSyncService()

    private let eventStore: EKEventStore
    private let queue = DispatchQueue(label: "com.trackit.calendar-sync")

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined, .writeOnly:
                eventStore.requestFullAccessToEvents { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied, .restricted:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        } else {
            switch status {
            case .authorized:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                eventStore.requestAccess(to: .event) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied, .restricted:
                DispatchQueue.main.async { completion(false) }
            case .fullAccess, .writeOnly:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    func syncEvent(for task: Task, completion: @escaping (String?) -> Void) {
        guard shouldHaveCalendarEvent(task) else {
            deleteEventIfPossible(identifier: task.calendarEventIdentifier) { deleted in
                completion(deleted ? nil : task.calendarEventIdentifier)
            }
            return
        }

        guard hasFullCalendarAccess else {
            DispatchQueue.main.async { completion(task.calendarEventIdentifier) }
            return
        }

        queue.async { [weak self] in
            guard let self,
                  let startDate = calendarStartDate(for: task),
                  let calendar = eventStore.defaultCalendarForNewEvents else {
                DispatchQueue.main.async { completion(task.calendarEventIdentifier) }
                return
            }

            let event = existingEvent(for: task.calendarEventIdentifier) ?? EKEvent(eventStore: eventStore)
            event.calendar = event.calendar ?? calendar
            event.title = eventTitle(for: task)
            event.startDate = startDate
            event.endDate = calendarEndDate(for: task, startDate: startDate)
            event.notes = "Создано в TrackIt"

            do {
                try eventStore.save(event, span: .thisEvent, commit: true)
                DispatchQueue.main.async { completion(event.eventIdentifier) }
            } catch {
                DispatchQueue.main.async { completion(task.calendarEventIdentifier) }
            }
        }
    }

    func deleteEvent(for task: Task) {
        deleteEventIfPossible(identifier: task.calendarEventIdentifier) { _ in }
    }

    private var hasFullCalendarAccess: Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }

    private func deleteEventIfPossible(identifier: String?, completion: @escaping (Bool) -> Void) {
        guard let identifier, !identifier.isEmpty else {
            DispatchQueue.main.async { completion(true) }
            return
        }

        guard hasFullCalendarAccess else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        queue.async { [weak self] in
            guard let self else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            guard let event = eventStore.event(withIdentifier: identifier) else {
                DispatchQueue.main.async { completion(true) }
                return
            }

            do {
                try eventStore.remove(event, span: .thisEvent, commit: true)
                DispatchQueue.main.async { completion(true) }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    private func shouldHaveCalendarEvent(_ task: Task) -> Bool {
        task.calendarSyncEnabled &&
        !task.isInbox &&
        task.dateScheduled != nil &&
        !(task.time ?? "").isEmpty
    }

    private func existingEvent(for identifier: String?) -> EKEvent? {
        guard let identifier, !identifier.isEmpty else { return nil }
        return eventStore.event(withIdentifier: identifier)
    }

    private func eventTitle(for task: Task) -> String {
        task.isCompleted ? "✓ \(task.title)" : task.title
    }

    private func calendarStartDate(for task: Task) -> Date? {
        guard let date = task.dateScheduled,
              let time = task.time,
              !time.isEmpty else { return nil }

        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }

        var components = RuDate.calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = parts[0]
        components.minute = parts[1]
        return RuDate.calendar.date(from: components)
    }

    private func calendarEndDate(for task: Task, startDate: Date) -> Date {
        let durationMinutes = max(Int(task.duration), 30)
        return RuDate.calendar.date(byAdding: .minute, value: durationMinutes, to: startDate)
            ?? startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }
}
