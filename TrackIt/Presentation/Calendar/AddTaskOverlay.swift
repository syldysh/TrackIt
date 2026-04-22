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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            sheetContent
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Sheet

    private var sheetContent: some View {
        VStack(spacing: 0) {
            grabHandle
            titleBar
            Group {
                if formVM.addDateMode == 2 {
                    ScrollView { formFields }
                } else {
                    formFields
                }
            }
        }
        .fixedSize(horizontal: false, vertical: formVM.addDateMode != 2)
        .frame(maxHeight: formVM.addDateMode == 2 ? UIScreen.main.bounds.height * 0.9 : nil)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    private var grabHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(.systemGray4))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 8)
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
                DatePicker("", selection: $formVM.newDate, in: RuDate.startOfDay(Date())..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                    .padding(.horizontal, 12)
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
                if mode == 0 { formVM.newDate = RuDate.startOfDay(Date()) }
                else if mode == 1 { formVM.newDate = RuDate.addDays(RuDate.startOfDay(Date()), 1) }
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
        withAnimation(.sheetSpring) { formVM.reset() }
        addFocused.wrappedValue = false
    }
}
