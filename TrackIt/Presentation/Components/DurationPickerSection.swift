//
//  DurationPickerSection.swift
//  TrackIt
//
//  Переиспользуемая секция выбора длительности.
//  Используется в AddTaskOverlay и SchedulePickerView.
//

import SwiftUI

struct DurationPickerSection: View {
    @Binding var isShowing: Bool
    @Binding var duration: Int16

    private var durHours: Binding<Int> {
        Binding(
            get: { Int(duration) / 60 },
            set: { duration = Int16($0 * 60 + Int(duration) % 60) }
        )
    }

    private var durMinutes: Binding<Int> {
        Binding(
            get: { Int(duration) % 60 },
            set: {
                let h = Int(duration) / 60
                let m = (h == 0 && $0 == 0) ? 1 : $0
                duration = Int16(h * 60 + m)
            }
        )
    }

    private var durMinStart: Int { Int(duration) / 60 == 0 ? 1 : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ДЛИТЕЛЬНОСТЬ")
                .sectionHeaderStyle()
                .padding(.leading, 24)
                .padding(.bottom, 8)

            if !isShowing {
                Button {
                    withAnimation(.smoothSpring) {
                        if duration == 0 { duration = 1 }
                        isShowing = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.placeholderText))
                        Text("Добавить длительность")
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
                    Picker("", selection: durHours) {
                        ForEach(0..<9, id: \.self) { h in
                            Text("\(h) ч").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .onChange(of: duration) { _, _ in
                        if Int(duration) / 60 == 0 && Int(duration) % 60 == 0 {
                            duration = 1
                        }
                    }

                    Picker("", selection: durMinutes) {
                        ForEach(durMinStart..<60, id: \.self) { m in
                            Text(String(format: "%02d мин", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Button {
                        withAnimation(.smoothSpring) {
                            duration = 0
                            isShowing = false
                        }
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
