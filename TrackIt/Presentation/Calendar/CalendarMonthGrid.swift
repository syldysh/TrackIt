//
//  CalendarMonthGrid.swift
//  TrackIt
//
//  Даты месячной сетки, разбитые на недели.
//

import Foundation

struct CalendarMonthGrid {
    let weeks: [[Date]]

    init(year: Int, month: Int) {
        let firstDayComponents = DateComponents(year: year, month: month + 1, day: 1)
        guard let firstDay = RuDate.calendar.date(from: firstDayComponents) else {
            self.weeks = []
            return
        }

        let gridStart = RuDate.weekStart(for: firstDay)
        let dayCount = RuDate.daysInMonth(year: year, month: month)
        let lastDay = RuDate.addDays(firstDay, dayCount - 1)
        let gridEnd = RuDate.addDays(RuDate.weekStart(for: lastDay), Constants.weekLength - 1)
        let totalDays = RuDate.calendar.dateComponents([.day], from: gridStart, to: gridEnd).day ?? Constants.weekLength - 1

        self.weeks = stride(from: 0, through: totalDays, by: Constants.weekLength).map { weekOffset in
            (0..<Constants.weekLength).map { dayOffset in
                RuDate.addDays(gridStart, weekOffset + dayOffset)
            }
        }
    }

    var days: [Date] {
        weeks.flatMap { $0 }
    }

    func selectedWeekIndex(for selectedDate: Date) -> Int {
        let selectedString = RuDate.isoString(from: selectedDate)
        return weeks.firstIndex { week in
            week.contains { RuDate.isoString(from: $0) == selectedString }
        } ?? 0
    }

    private enum Constants {
        static let weekLength = 7
    }
}
