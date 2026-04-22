//
//  TimePickerSection.swift
//  TrackIt
//
//  Переиспользуемая секция выбора времени.
//  Используется в AddTaskOverlay и SchedulePickerView.
//

import SwiftUI

struct TimePickerSection: View {
    @Binding var isShowing: Bool
    @Binding var timeDate: Date

    private var timeHour: Binding<Int> {
        Binding(
            get: { RuDate.calendar.component(.hour, from: timeDate) },
            set: {
                var comps = RuDate.calendar.dateComponents([.year, .month, .day, .minute], from: timeDate)
                comps.hour = $0
                timeDate = RuDate.calendar.date(from: comps) ?? timeDate
            }
        )
    }

    private var timeMinute: Binding<Int> {
        Binding(
            get: { RuDate.calendar.component(.minute, from: timeDate) },
            set: {
                var comps = RuDate.calendar.dateComponents([.year, .month, .day, .hour], from: timeDate)
                comps.minute = $0
                timeDate = RuDate.calendar.date(from: comps) ?? timeDate
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ВРЕМЯ")
                .sectionHeaderStyle()
                .padding(.leading, 24)
                .padding(.bottom, 8)

            if !isShowing {
                Button {
                    timeDate = Date()
                    withAnimation(.smoothSpring) { isShowing = true }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.placeholderText))
                        Text("Добавить время")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.placeholderText))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            } else {
                HStack(spacing: 0) {
                    Picker("", selection: timeHour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d ч", h)).tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("", selection: timeMinute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text(String(format: "%02d мин", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Button {
                        withAnimation(.smoothSpring) { isShowing = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(.systemGray3))
                    }
                    .padding(.trailing, 8)
                }
                .frame(height: 120)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
