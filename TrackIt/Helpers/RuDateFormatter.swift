//
//  RuDateFormatter.swift
//  TrackIt
//
//  Утилиты для форматирования дат.
//  Используем DateFormatter + Calendar, чтобы система сама давала правильные названия.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

enum RuDate {

    static let locale = Locale(identifier: "ru_RU")
    private static let formatterLock = NSLock()

    // Единый календарь приложения: ru_RU, понедельник первым днём недели.
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        cal.firstWeekday = 2
        cal.timeZone = .autoupdatingCurrent
        return cal
    }()

    // 1 января 2024 — понедельник; от него строим подписи дней через Foundation.
    private static let weekdayReferenceMonday: Date = {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: 2024,
            month: 1,
            day: 1
        )
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 1_704_067_200)
    }()

    private static let shortWeekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = locale
        f.calendar = calendar
        f.timeZone = calendar.timeZone
        f.setLocalizedDateFormatFromTemplate("EEE")
        return f
    }()

    private static func normalizeWeekdayIndex(_ index: Int) -> Int {
        let count = calendar.maximumRange(of: .weekday)?.count ?? 0
        guard count > 0 else { return 0 }
        return ((index % count) + count) % count
    }

    static var shortWeekdays: [String] {
        let count = calendar.maximumRange(of: .weekday)?.count ?? 0
        return (0..<count).map(shortWeekday)
    }

    static func shortWeekday(at index: Int) -> String {
        let idx = normalizeWeekdayIndex(index)
        let date = calendar.date(byAdding: .day, value: idx, to: weekdayReferenceMonday) ?? weekdayReferenceMonday
        return normalizeWeekdaySymbol(string(from: date, using: shortWeekdayFormatter))
    }

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = calendar
        f.timeZone = calendar.timeZone
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = locale
        f.calendar = calendar
        f.timeZone = calendar.timeZone
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    private static let dayMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = locale
        f.calendar = calendar
        f.timeZone = calendar.timeZone
        f.dateFormat = "d MMMM"
        return f
    }()

    static func isoString(from date: Date) -> String {
        string(from: date, using: isoFormatter)
    }

    static func isoWeekday(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 ? 6 : weekday - 2
    }

    static func weekStart(for date: Date) -> Date {
        calendar.date(byAdding: .day, value: -isoWeekday(date), to: startOfDay(date))
            ?? startOfDay(date)
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func startOfMonth(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components).map(startOfDay) ?? startOfDay(date)
    }

    static func addDays(_ date: Date, _ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    static func daysInMonth(year: Int, month: Int) -> Int {
        let components = DateComponents(year: year, month: month + 1)
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30
        }
        return range.count
    }

    static func firstWeekdayOfMonth(year: Int, month: Int) -> Int {
        let components = DateComponents(year: year, month: month + 1, day: 1)
        guard let date = calendar.date(from: components) else { return 0 }
        return isoWeekday(date)
    }

    static func dateDayLabel(_ date: Date) -> String {
        let weekday = isoWeekday(date)
        return "\(shortWeekday(at: weekday)), \(string(from: date, using: dayMonthFormatter))"
    }

    static func dayLabel(_ date: Date) -> String {
        let today = startOfDay(Date())
        let target = startOfDay(date)

        if isoString(from: target) == isoString(from: today) { return "Сегодня" }
        if isoString(from: target) == isoString(from: addDays(today, 1)) { return "Завтра" }

        let weekday = isoWeekday(date)
        return "\(shortWeekday(at: weekday)), \(string(from: date, using: dayMonthFormatter))"
    }

    static func shortDayLabel(_ date: Date) -> String {
        let today = startOfDay(Date())
        let target = startOfDay(date)

        if isoString(from: target) == isoString(from: today) { return "Сегодня" }
        if isoString(from: target) == isoString(from: addDays(today, 1)) { return "Завтра" }

        return string(from: date, using: dayMonthFormatter)
    }

    static func monthYearTitle(year: Int, month: Int) -> String {
        let components = DateComponents(year: year, month: month + 1, day: 1)
        guard let date = calendar.date(from: components) else { return "" }
        return monthYearTitle(for: date)
    }

    static func monthYearTitle(for date: Date) -> String {
        string(from: date, using: monthYearFormatter)
    }

    // DateFormatter не потокобезопасен, поэтому общий доступ закрыт lock-ом.
    private static func string(from date: Date, using formatter: DateFormatter) -> String {
        formatterLock.lock()
        defer { formatterLock.unlock() }
        return formatter.string(from: date)
    }

    private static func normalizeWeekdaySymbol(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ".", with: "")
        guard let first = trimmed.first else { return "" }
        return String(first).uppercased(with: locale) + String(trimmed.dropFirst())
    }

    static func pluralTasks(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "задача" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "задачи" }
        return "задач"
    }
}
