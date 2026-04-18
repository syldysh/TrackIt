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
    let onSchedule: (Date, String?, Int16) -> Void
    let onCancel: () -> Void

    @State private var schedDate: Date? = RuDate.startOfDay(Date())
    @State private var nativeDateSelection = Date()
    @State private var showTimePicker = false
    @State private var timeDate = Date()
    @State private var selectedDuration: Int16 = 0
    @State private var showDurationPicker = false

    private var today: Date { RuDate.startOfDay(Date()) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                Spacer()
                sheetContent
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(TabBarHider(hide: true))
    }

    // MARK: - Sheet

    private var sheetContent: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    taskTitle
                    monthPicker
                    TimePickerSection(isShowing: $showTimePicker, timeDate: $timeDate)
                    DurationPickerSection(isShowing: $showDurationPicker, duration: $selectedDuration)
                    confirmButton
                    cancelButton
                }
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    // MARK: - Title

    private var taskTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Когда выполнить?")
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
            Text("\"\(task.title)\"")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.label))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Month Picker

    private var monthPicker: some View {
        DatePicker("", selection: $nativeDateSelection, in: today..., displayedComponents: .date)
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
            .onChange(of: nativeDateSelection) { _, val in
                schedDate = RuDate.startOfDay(val)
            }
    }

    // MARK: - Buttons

    private var confirmButton: some View {
        Button {
            if let date = schedDate {
                let timeStr: String? = showTimePicker
                    ? String(format: "%02d:%02d",
                             RuDate.calendar.component(.hour, from: timeDate),
                             RuDate.calendar.component(.minute, from: timeDate))
                    : nil
                onSchedule(date, timeStr, selectedDuration)
            }
        } label: {
            Text(schedDate.map { "Запланировать на \(RuDate.shortDayLabel($0))" } ?? "Выберите дату")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.brandAccent.opacity(schedDate != nil ? 1 : 0.35))
                .cornerRadius(16)
        }
        .disabled(schedDate == nil)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var cancelButton: some View {
        Button { onCancel() } label: {
            Text("Отмена — оставить в планировщике")
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
