//
//  SchedulePickerView.swift
//  TrackIt
//
//  Модальный экран выбора даты при планировании задачи.
//  Использует TimePickerSection и DurationPickerSection из Components/.
//

import SwiftUI

struct SchedulePickerView: View {
    let task: Task
    let onSchedule: (Date, String?, Int16, Bool, Bool) -> Void
    let onCancel: () -> Void

    @StateObject private var formVM: SchedulePickerViewModel
    @ObservedObject var dragState: ModalDragState

    init(
        task: Task,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        dragState: ModalDragState,
        onSchedule: @escaping (Date, String?, Int16, Bool, Bool) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.task = task
        self.onSchedule = onSchedule
        self.onCancel = onCancel
        self.dragState = dragState
        _formVM = StateObject(
            wrappedValue: SchedulePickerViewModel(
                notificationService: notificationService,
                calendarSyncService: calendarSyncService
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onCancel() }

            sheetContent
                .modalDragOffset(dragState)
                .contentShape(Rectangle())
                .onTapGesture { }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(TabBarHider(hide: true).allowsHitTesting(false))
    }

    private var sheetContent: some View {
        VStack(spacing: 0) {
            ModalDragHandle(dragState: dragState, onDismiss: onCancel) {
                EmptyView()
            }
            .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    taskTitle
                    monthPicker
                    TimePickerSection(isShowing: $formVM.showTimePicker, timeDate: $formVM.timeDate)
                        .onChange(of: formVM.showTimePicker) { _, isShowing in
                            if !isShowing {
                                formVM.disableReminder()
                                formVM.disableCalendarSync()
                            }
                        }
                    if formVM.canShowReminderToggle {
                        NotificationToggleSection(
                            isOn: formVM.reminderEnabled,
                            message: formVM.notificationPermissionMessage,
                            onChange: { formVM.setReminderEnabled($0) }
                        )
                    }
                    if formVM.canShowCalendarSyncToggle {
                        CalendarSyncToggleSection(
                            isOn: formVM.calendarSyncEnabled,
                            message: formVM.calendarPermissionMessage,
                            onChange: { formVM.setCalendarSyncEnabled($0) }
                        )
                    }
                    DurationPickerSection(isShowing: $formVM.showDurationPicker, duration: $formVM.selectedDuration)
                    confirmButton
                    cancelButton
                }
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    private var taskTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Когда выполнить?")
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
            Text("\"\(task.title)\"")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.label))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var monthPicker: some View {
        DatePicker("", selection: $formVM.nativeDateSelection, in: formVM.today..., displayedComponents: .date)
            .datePickerStyle(.graphical)
            .environment(\.locale, RuDate.locale)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
            .onChange(of: formVM.nativeDateSelection) { _, val in
                formVM.updateDateSelection(val)
            }
    }

    private var confirmButton: some View {
        Button {
            if let date = formVM.schedDate {
                onSchedule(
                    date,
                    formVM.timeString,
                    formVM.selectedDuration,
                    formVM.shouldScheduleReminder,
                    formVM.shouldSyncCalendar
                )
            }
        } label: {
            Text(formVM.schedDate.map { "Запланировать на \(RuDate.shortDayLabel($0))" } ?? "Выберите дату")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.brandAccent.opacity(formVM.schedDate != nil ? 1 : 0.35))
                .cornerRadius(16)
        }
        .disabled(formVM.schedDate == nil)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var cancelButton: some View {
        Button { onCancel() } label: {
            Text("Отмена — оставить в планировщике")
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
                .lineLimit(2)
                .minimumScaleFactor(0.86)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
