//
//  CalendarMonthGrid.swift
//  TrackIt
//
//  Даты месячной сетки, разбитые на недели.
//

import Foundation

struct CalendarMonthGrid {
    struct Day: Identifiable, Hashable {
        let id: Int
        let date: Date?
    }

    let weeks: [[Day]]

    init(year: Int, month: Int) {
        let dayCount = RuDate.daysInMonth(year: year, month: month)
        let leadingEmptySlots = RuDate.firstWeekdayOfMonth(year: year, month: month)
        let cellCount = ((leadingEmptySlots + dayCount + Constants.weekLength - 1) / Constants.weekLength) * Constants.weekLength

        guard cellCount > 0 else {
            self.weeks = []
            return
        }

        let days = (0..<cellCount).map { index in
            let dayNumber = index - leadingEmptySlots + 1
            let date = Self.makeDate(year: year, month: month, day: dayNumber, dayCount: dayCount)
            return Day(id: index, date: date)
        }

        self.weeks = stride(from: 0, to: days.count, by: Constants.weekLength).map { startIndex in
            Array(days[startIndex..<min(startIndex + Constants.weekLength, days.count)])
        }
    }

    private static func makeDate(year: Int, month: Int, day: Int, dayCount: Int) -> Date? {
        guard (1...dayCount).contains(day) else { return nil }
        return RuDate.calendar.date(
            from: DateComponents(
                year: year,
                month: month + 1,
                day: day
            )
        ).map(RuDate.startOfDay)
    }

    var days: [Day] {
        weeks.flatMap { $0 }
    }

    func selectedWeekIndex(for selectedDate: Date) -> Int {
        let selectedString = RuDate.isoString(from: selectedDate)
        return weeks.firstIndex { week in
            week.contains { day in
                guard let date = day.date else { return false }
                return RuDate.isoString(from: date) == selectedString
            }
        } ?? 0
    }

    private enum Constants {
        static let weekLength = 7
    }
}
