//
//  PlanningScheduleOverlayView.swift
//  TrackIt
//
//  Overlay выбора даты для задачи в планировщике.
//

import SwiftUI

struct PlanningScheduleOverlayView: View {
    let task: Task?
    @StateObject private var formVM: SchedulePickerViewModel
    @ObservedObject var dragState: ModalDragState
    let onSchedule: (Task, Date, String?, Int16, Bool, Bool) -> Void
    let onCancel: () -> Void

    init(
        task: Task?,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        dragState: ModalDragState,
        onSchedule: @escaping (Task, Date, String?, Int16, Bool, Bool) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.task = task
        self.dragState = dragState
        self.onSchedule = onSchedule
        self.onCancel = onCancel
        _formVM = StateObject(
            wrappedValue: SchedulePickerViewModel(
                notificationService: notificationService,
                calendarSyncService: calendarSyncService
            )
        )
    }

    var body: some View {
        ZStack {
            ModalDimBackground(dragState: dragState, baseOpacity: 0.32, onTap: onCancel)
                .transition(.opacity)
                .zIndex(19)

            if let task {
                SchedulePickerView(
                    task: task,
                    formVM: formVM,
                    dragState: dragState,
                    onSchedule: { date, time, duration, reminderEnabled, calendarSyncEnabled in
                        onSchedule(task, date, time, duration, reminderEnabled, calendarSyncEnabled)
                    },
                    onCancel: onCancel
                )
                .transition(.move(edge: .bottom))
                .zIndex(20)
            }
        }
    }
}
