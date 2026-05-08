//
//  CalendarMonthPickerView.swift
//  TrackIt
//
//  Переиспользуемый компактный календарь месяца для выбора даты.
//

import SwiftUI

struct CalendarMonthPickerView: View {
    let displayedMonth: Date
    let selectedDate: Date
    let minimumDate: Date?
    let canGoToPreviousMonth: Bool
    let showsTodayButton: Bool
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onToday: () -> Void
    let onSelectDay: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            monthHeader
            weekdayHeader
            dayGrid
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
    }

    private var monthHeader: some View {
        HStack(spacing: 10) {
            navButton(icon: "chevron.left", isEnabled: canGoToPreviousMonth, action: onPreviousMonth)

            Text(RuDate.monthYearTitle(for: displayedMonth))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.label))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity)

            if showsTodayButton {
                CalendarTodayButton(action: onToday)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            navButton(icon: "chevron.right", isEnabled: true, action: onNextMonth)
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
        let year = RuDate.calendar.component(.year, from: displayedMonth)
        let month = RuDate.calendar.component(.month, from: displayedMonth) - 1
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
        let date = dateInDisplayedMonth(day: day)
        let isSelected = date.map { RuDate.calendar.isDate($0, inSameDayAs: selectedDate) } ?? false
        let isDisabled = date.map(isDisabledDay) ?? true

        return Button {
            withAnimation(.snappySpring) {
                onSelectDay(day)
            }
        } label: {
            Text("\(day)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dayTextColor(isSelected: isSelected, isDisabled: isDisabled))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(dayBackground(isSelected: isSelected, isDisabled: isDisabled))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
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

    private func dateInDisplayedMonth(day: Int) -> Date? {
        let year = RuDate.calendar.component(.year, from: displayedMonth)
        let month = RuDate.calendar.component(.month, from: displayedMonth)
        return RuDate.calendar.date(from: DateComponents(year: year, month: month, day: day))
            .map(RuDate.startOfDay)
    }

    private func isDisabledDay(_ date: Date) -> Bool {
        guard let minimumDate else { return false }
        return date < RuDate.startOfDay(minimumDate)
    }

    private func dayTextColor(isSelected: Bool, isDisabled: Bool) -> Color {
        if isSelected { return .white }
        if isDisabled { return Color(.tertiaryLabel) }
        return Color(.label)
    }

    private func dayBackground(isSelected: Bool, isDisabled: Bool) -> Color {
        if isSelected { return .brandAccent }
        if isDisabled { return Color(.systemGray6).opacity(0.45) }
        return Color(.systemGray6)
    }
}
