//
//  PlanningScheduleOverlayView.swift
//  TrackIt
//
//  Overlay выбора даты для задачи из режима планирования.
//

import SwiftUI

struct PlanningScheduleOverlayView: View {
    let task: Task?
    let notificationService: any NotificationServiceProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol
    @ObservedObject var dragState: ModalDragState
    let onSchedule: (Task, Date, String?, Int16, Bool, Bool) -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            ModalDimBackground(dragState: dragState, baseOpacity: 0.32, onTap: onCancel)
                .transition(.opacity)
                .zIndex(19)

            if let task {
                SchedulePickerView(
                    task: task,
                    notificationService: notificationService,
                    calendarSyncService: calendarSyncService,
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
