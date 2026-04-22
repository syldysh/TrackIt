//
//  AddTaskViewModel.swift
//  TrackIt
//
//  Форм-стейт для добавления / редактирования задачи.
//  Выделен из CalendarViewModel, чтобы снять с него лишние ответственности.
//

import Foundation
import Combine

final class AddTaskViewModel: ObservableObject {

    // MARK: - Состояние формы

    @Published var showAddTask = false
    @Published var editingTask: Task? = nil
    @Published var newTitle = ""
    @Published var newDate: Date = RuDate.startOfDay(Date())
    @Published var showTimePicker = false
    @Published var timeDate = Date()
    @Published var addDateMode: Int = 0
    @Published var newDuration: Int16 = 0
    @Published var showDurationPicker = false

    // MARK: - Зависимость

    private let repository: any TaskRepositoryProtocol

    // MARK: - Init

    init(repository: any TaskRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Вычисляемые свойства

    var canAddTask: Bool {
        !newTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Открыть форму (новая задача)

    func prepareAddTask(selectedDate: Date) {
        let today = RuDate.startOfDay(Date())
        let tomorrow = RuDate.addDays(today, 1)
        if selectedDate >= today {
            newDate = selectedDate
            if RuDate.isoString(from: selectedDate) == RuDate.isoString(from: today) {
                addDateMode = 0
            } else if RuDate.isoString(from: selectedDate) == RuDate.isoString(from: tomorrow) {
                addDateMode = 1
            } else {
                addDateMode = 2
            }
        } else {
            newDate = today
            addDateMode = 0
        }
        showTimePicker = false
        showAddTask = true
    }

    // Тап по сетке дня без конкретной даты
    func prepareAddTaskAt(hour: Int, minute: Int) {
        prepareAddTask(selectedDate: newDate)
        showTimePicker = true
        var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: newDate)
        comps.hour = hour
        comps.minute = minute
        timeDate = RuDate.calendar.date(from: comps) ?? Date()
    }

    // Тап по сетке в модальном окне — конкретная дата
    func prepareAddTaskAt(hour: Int, minute: Int, date: Date) {
        newDate = RuDate.startOfDay(date)
        addDateMode = 2
        showAddTask = true
        newTitle = ""
        showTimePicker = true
        var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = minute
        timeDate = RuDate.calendar.date(from: comps) ?? Date()
    }

    // MARK: - Открыть форму (редактирование существующей задачи)

    func prepareEditTask(_ task: Task) {
        editingTask = task
        newTitle = task.title

        let date = task.dateScheduled ?? RuDate.startOfDay(Date())
        newDate = date
        let today = RuDate.startOfDay(Date())
        let tomorrow = RuDate.addDays(today, 1)
        if RuDate.isoString(from: date) == RuDate.isoString(from: today) {
            addDateMode = 0
        } else if RuDate.isoString(from: date) == RuDate.isoString(from: tomorrow) {
            addDateMode = 1
        } else {
            addDateMode = 2
        }

        if let time = task.time, !time.isEmpty {
            showTimePicker = true
            let parts = time.split(separator: ":").compactMap { Int($0) }
            if parts.count == 2 {
                var comps = RuDate.calendar.dateComponents([.year, .month, .day], from: Date())
                comps.hour = parts[0]
                comps.minute = parts[1]
                timeDate = RuDate.calendar.date(from: comps) ?? Date()
            }
        } else {
            showTimePicker = false
        }

        newDuration = task.duration
        showDurationPicker = task.duration > 0
        showAddTask = true
    }

    // MARK: - Подтвердить (создать / обновить)

    func commitAddTask() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        let timeStr: String? = showTimePicker
            ? String(format: "%02d:%02d",
                     RuDate.calendar.component(.hour, from: timeDate),
                     RuDate.calendar.component(.minute, from: timeDate))
            : nil

        if let task = editingTask {
            repository.update(task, title: title, date: newDate, time: timeStr, duration: newDuration)
        } else {
            repository.addScheduledTask(title: title, date: newDate, time: timeStr, duration: newDuration)
        }
        reset()
    }

    // MARK: - Сбросить форму

    func reset() {
        showAddTask = false
        editingTask = nil
        newTitle = ""
        showTimePicker = false
        showDurationPicker = false
        addDateMode = 0
        newDuration = 0
        newDate = RuDate.startOfDay(Date())
    }
}
