//
//  AddTaskViewModel+Reset.swift
//  TrackIt
//
//  Сброс состояния формы задачи.
//

import Foundation

extension AddTaskViewModel {

    // MARK: - Сбросить форму

    func hideForm() {
        showAddTask = false
    }

    func clearFormState() {
        editingTask = nil
        newTitle = ""
        showTimePicker = false
        showDurationPicker = false
        addDateMode = 0
        newDuration = 0
        newDate = RuDate.startOfDay(Date())
        reminderEnabled = false
        notificationPermissionMessage = nil
        calendarSyncEnabled = false
        calendarPermissionMessage = nil
    }

    func reset() {
        hideForm()
        clearFormState()
    }
}
