//
//  AddTaskOverlay.swift
//  TrackIt
//
//  Модальный экран добавления / редактирования задачи.
//  Читает форм-стейт из vm.addTaskVM.
//

import SwiftUI

struct AddTaskOverlay: View {
    @EnvironmentObject var vm: CalendarViewModel
    // Отдельный ObservedObject — чтобы работали $-биндинги к @Published-свойствам
    @ObservedObject var formVM: AddTaskViewModel
    var addFocused: FocusState<Bool>.Binding
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            sheetContent
                .offset(y: dragState.offset)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Sheet

    private var sheetContent: some View {
        VStack(spacing: 0) {
            dragArea
            Group {
                if shouldScrollForm {
                    ScrollView { formFields }
                } else {
                    formFields
                }
            }
        }
        .fixedSize(horizontal: false, vertical: !shouldScrollForm)
        .frame(maxHeight: shouldScrollForm ? UIScreen.main.bounds.height * 0.9 : nil)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    private var shouldScrollForm: Bool {
        formVM.addDateMode == 2 || formVM.showTimePicker || formVM.showDurationPicker
    }

    private var dragArea: some View {
        ModalDragHandle(dragState: dragState, onDismiss: dismiss) {
            titleBar
        }
    }

    private var titleBar: some View {
        HStack {
            Text(formVM.editingTask != nil ? "Редактировать" : "Новая задача")
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleField
            dateSection
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
            DurationPickerSection(isShowing: $formVM.showDurationPicker, duration: $formVM.newDuration)
            actionButtons
        }
    }

    private var titleField: some View {
        TextField("Название задачи", text: $formVM.newTitle)
            .focused(addFocused)
            .font(.system(size: 17))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ДАТА")
                .sectionHeaderStyle()
                .padding(.leading, 24)
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                datePill("Сегодня", mode: 0)
                datePill("Завтра", mode: 1)
                datePill("Другая", mode: 2, icon: "calendar")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            if formVM.addDateMode == 2 {
                DateSelectionCalendarView(selectedDate: $formVM.newDate, minimumDate: RuDate.startOfDay(Date()))
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
    }

    private func datePill(_ label: String, mode: Int, icon: String? = nil) -> some View {
        let isSelected = formVM.addDateMode == mode

        return Button {
            withAnimation(.smoothSpring) {
                formVM.addDateMode = mode
                if mode == 0 {
                    formVM.newDate = RuDate.startOfDay(Date())
                } else if mode == 1 {
                    formVM.newDate = RuDate.addDays(RuDate.startOfDay(Date()), 1)
                }
            }
        } label: {
            HStack(spacing: 4) {
                if isSelected && mode != 2 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                }
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.brandAccent : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : Color(.label))
            .cornerRadius(20)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Text("Отмена")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
            }
            Button {
                formVM.commitAddTask()
                addFocused.wrappedValue = false
            } label: {
                Text(formVM.editingTask != nil ? "Сохранить" : "Добавить")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(formVM.canAddTask ? Color.brandAccent : Color.brandAccent.opacity(0.35))
                    .cornerRadius(16)
                    .animation(.smoothSpring, value: formVM.newTitle)
            }
            .disabled(!formVM.canAddTask)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Dismiss

    private func dismiss() {
        onDismiss()
    }
}
