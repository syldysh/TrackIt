//
//  ScheduleMonthPickerView.swift
//  TrackIt
//
//  Контролируемый календарь для режима планирования.
//  Сохраняет выбранный номер дня при переключении месяцев.
//

import SwiftUI

struct ScheduleMonthPickerView: View {
    @ObservedObject var formVM: SchedulePickerViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            todayButtonRow
            monthHeader
            weekdayHeader
            dayGrid
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var todayButtonRow: some View {
        if formVM.shouldShowTodayButton {
            HStack {
                Spacer()
                todayButton()
            }
            .padding(.horizontal, 8)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 10) {
            navButton(icon: "chevron.left", isEnabled: formVM.canGoToPreviousMonth) {
                formVM.goToPreviousMonth()
            }

            Text(formVM.displayedMonthTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.label))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)

            navButton(icon: "chevron.right", isEnabled: true) {
                formVM.goToNextMonth()
            }
        }
        .padding(.horizontal, 8)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(RuDate.shortWeekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(height: 24)
            }
        }
    }

    private var dayGrid: some View {
        let year = RuDate.calendar.component(.year, from: formVM.displayedMonth)
        let month = RuDate.calendar.component(.month, from: formVM.displayedMonth) - 1
        let dayCount = RuDate.daysInMonth(year: year, month: month)
        let leadingEmptySlots = RuDate.firstWeekdayOfMonth(year: year, month: month)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<(leadingEmptySlots + dayCount), id: \.self) { index in
                if index < leadingEmptySlots {
                    Color.clear.frame(height: 42)
                } else {
                    dayCell(index - leadingEmptySlots + 1)
                }
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let isSelected = formVM.isSelectedDay(day)
        let isPast = formVM.isPastDay(day)

        return Button {
            withAnimation(.snappySpring) {
                formVM.selectDayInDisplayedMonth(day)
            }
        } label: {
            Text("\(day)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dayTextColor(isSelected: isSelected, isPast: isPast))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(dayBackground(isSelected: isSelected, isPast: isPast))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isPast)
    }

    private func todayButton() -> some View {
        Button {
            withAnimation(.smoothSpring) { formVM.goToToday() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12, weight: .semibold))
                Text("Сегодня")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .frame(maxWidth: 88)
            .foregroundColor(.white)
            .background(Color.brandAccent)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func navButton(icon: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.smoothSpring) { action() }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isEnabled ? Color(.secondaryLabel) : Color(.tertiaryLabel))
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private func dayTextColor(isSelected: Bool, isPast: Bool) -> Color {
        if isSelected { return .white }
        if isPast { return Color(.tertiaryLabel) }
        return Color(.label)
    }

    private func dayBackground(isSelected: Bool, isPast: Bool) -> Color {
        if isSelected { return .brandAccent }
        if isPast { return Color(.systemGray6).opacity(0.45) }
        return Color(.systemGray6)
    }
}
