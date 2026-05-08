//
//  DateSelectionCalendarView.swift
//  TrackIt
//
//  Календарь выбора даты с сохранением выбранного числа между месяцами.
//

import SwiftUI

struct DateSelectionCalendarView: View {
    @Binding var selectedDate: Date
    let minimumDate: Date?
    @State private var displayedMonth: Date

    init(selectedDate: Binding<Date>, minimumDate: Date? = nil) {
        _selectedDate = selectedDate
        self.minimumDate = minimumDate.map(RuDate.startOfDay)
        _displayedMonth = State(initialValue: RuDate.startOfMonth(selectedDate.wrappedValue))
    }

    var body: some View {
        CalendarMonthPickerView(
            displayedMonth: displayedMonth,
            selectedDate: selectedDate,
            minimumDate: minimumDate,
            canGoToPreviousMonth: canGoToPreviousMonth,
            showsTodayButton: shouldShowTodayButton,
            onPreviousMonth: { moveMonth(by: -1) },
            onNextMonth: { moveMonth(by: 1) },
            onToday: goToToday,
            onSelectDay: selectDay
        )
        .onAppear { syncDisplayedMonth() }
        .onChange(of: selectedDate) { _, _ in syncDisplayedMonth() }
    }

    private var canGoToPreviousMonth: Bool {
        guard let minimumDate else { return true }
        return displayedMonth > RuDate.startOfMonth(minimumDate)
    }

    private var shouldShowTodayButton: Bool {
        let today = RuDate.startOfDay(Date())
        let currentMonth = RuDate.startOfMonth(today)
        return !RuDate.calendar.isDate(selectedDate, inSameDayAs: today)
            || !RuDate.calendar.isDate(displayedMonth, equalTo: currentMonth, toGranularity: .month)
    }

    private func goToToday() {
        let today = RuDate.startOfDay(Date())
        selectedDate = constrainedDate(today)
        displayedMonth = RuDate.startOfMonth(selectedDate)
    }

    private func moveMonth(by value: Int) {
        guard let month = RuDate.calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        let normalizedMonth = RuDate.startOfMonth(month)
        guard canDisplay(month: normalizedMonth) else { return }

        displayedMonth = normalizedMonth
        selectPreservedDay(in: normalizedMonth)
    }

    private func selectDay(_ day: Int) {
        guard let date = date(in: displayedMonth, day: day),
              canSelect(date: date) else {
            return
        }
        selectedDate = date
        displayedMonth = RuDate.startOfMonth(date)
    }

    private func selectPreservedDay(in month: Date) {
        let preferredDay = RuDate.calendar.component(.day, from: selectedDate)
        let year = RuDate.calendar.component(.year, from: month)
        let monthIndex = RuDate.calendar.component(.month, from: month) - 1
        let day = min(preferredDay, RuDate.daysInMonth(year: year, month: monthIndex))
        guard let date = date(in: month, day: day) else { return }

        selectedDate = constrainedDate(date)
        displayedMonth = RuDate.startOfMonth(selectedDate)
    }

    private func syncDisplayedMonth() {
        selectedDate = constrainedDate(selectedDate)
        displayedMonth = RuDate.startOfMonth(selectedDate)
    }

    private func constrainedDate(_ date: Date) -> Date {
        let day = RuDate.startOfDay(date)
        guard let minimumDate, day < minimumDate else { return day }
        return minimumDate
    }

    private func canDisplay(month: Date) -> Bool {
        guard let minimumDate else { return true }
        return month >= RuDate.startOfMonth(minimumDate)
    }

    private func canSelect(date: Date) -> Bool {
        guard let minimumDate else { return true }
        return date >= minimumDate
    }

    private func date(in month: Date, day: Int) -> Date? {
        let year = RuDate.calendar.component(.year, from: month)
        let monthNumber = RuDate.calendar.component(.month, from: month)
        return RuDate.calendar.date(from: DateComponents(year: year, month: monthNumber, day: day))
            .map(RuDate.startOfDay)
    }
}
