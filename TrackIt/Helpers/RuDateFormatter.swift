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

// MARK: - Форматтеры (создаём один раз, используем везде)

enum RuDate {

    private static let locale = Locale(identifier: "ru_RU")
    private static let fallbackShortWeekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    private static let fallbackMonthNamesNominative = [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]
    private static let fallbackMonthNamesGenitive = [
        "Января", "Февраля", "Марта", "Апреля", "Мая", "Июня",
        "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"
    ]

    // Календарь с понедельником как первым днём недели
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        cal.firstWeekday = 2
        return cal
    }()

    // MARK: - Короткие названия дней недели

    // "Пн", ... , "Вс"
    static let shortWeekdays: [String] = {
        let formatter = DateFormatter()
        formatter.locale = locale

        let symbols = formatter.shortStandaloneWeekdaySymbols
            ?? formatter.shortWeekdaySymbols
            ?? ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        guard symbols.count == 7 else {
            return fallbackShortWeekdays
        }
        // У DateFormatter неделя начинается с воскресенья, сдвигаем на понедельник
        guard let first = symbols.first else { return fallbackShortWeekdays }
        return Array(symbols.dropFirst()) + [first]
    }()

    // MARK: - Названия месяцев

    // Формат: "Month year"
    static let monthNamesNominative: [String] = {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.standaloneMonthSymbols
    }()

    // Используется в контексте: «5 Января» и тд
    static let monthNamesGenitive: [String] = {
        let formatter = DateFormatter()
        formatter.locale = locale
        // Делаем первую букву заглавной
        return formatter.monthSymbols.map { $0.prefix(1).uppercased() + $0.dropFirst() }
    }()

    private static func normalizeWeekdayIndex(_ index: Int) -> Int {
        let count = fallbackShortWeekdays.count
        return ((index % count) + count) % count
    }

    private static func normalizeMonthIndex(_ index: Int) -> Int {
        let count = fallbackMonthNamesNominative.count
        return ((index % count) + count) % count
    }

    static func shortWeekday(at index: Int) -> String {
        let idx = normalizeWeekdayIndex(index)
        return shortWeekdays[safe: idx] ?? fallbackShortWeekdays[safe: idx] ?? "Пн"
    }

    static func monthNameNominative(at index: Int) -> String {
        let idx = normalizeMonthIndex(index)
        return monthNamesNominative[safe: idx] ?? fallbackMonthNamesNominative[safe: idx] ?? "Январь"
    }

    static func monthNameGenitive(at index: Int) -> String {
        let idx = normalizeMonthIndex(index)
        return monthNamesGenitive[safe: idx] ?? fallbackMonthNamesGenitive[safe: idx] ?? "Января"
    }

    // MARK: - Форматирование дат

    // Создаётся один раз — DateFormatter дорогой объект, не создаём каждый вызов
    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // Формат yyyy-MM-dd
    static func isoString(from date: Date) -> String {
        isoFormatter.string(from: date)
    }

    // Разбирает ISO-строку обратно в Date
    static func date(from iso: String) -> Date {
        isoFormatter.date(from: iso) ?? Date()
    }

    // ISO-номер дня недели: 0 = Пн, 1 = Вт, ..., 6 = Вс
    static func isoWeekday(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 ? 6 : weekday - 2
    }

    static func weekStart(for date: Date) -> Date {
        calendar.date(byAdding: .day, value: -isoWeekday(date), to: startOfDay(date))
            ?? startOfDay(date)
    }

    // Начало дня (00:00)
    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Сдвиг на N дней
    static func addDays(_ date: Date, _ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    // Количество дней в месяце
    static func daysInMonth(year: Int, month: Int) -> Int {
        let components = DateComponents(year: year, month: month + 1)
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30
        }
        return range.count
    }

    // День недели первого числа месяца
    static func firstWeekdayOfMonth(year: Int, month: Int) -> Int {
        let components = DateComponents(year: year, month: month + 1, day: 1)
        guard let date = calendar.date(from: components) else { return 0 }
        return isoWeekday(date)
    }

    // MARK: - Подписи для UI

    // Всегда «Пн, 5 Января» — без замены на Сегодня/Завтра
    static func dateDayLabel(_ date: Date) -> String {
        let weekday = isoWeekday(date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date) - 1
        return "\(shortWeekday(at: weekday)), \(day) \(monthNameGenitive(at: month))"
    }

    // «Сегодня», «Завтра» или «Пн, 5 Января»
    static func dayLabel(_ date: Date) -> String {
        let today = startOfDay(Date())
        let target = startOfDay(date)

        if isoString(from: target) == isoString(from: today) { return "Сегодня" }
        if isoString(from: target) == isoString(from: addDays(today, 1)) { return "Завтра" }

        let weekday = isoWeekday(date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date) - 1
        return "\(shortWeekday(at: weekday)), \(day) \(monthNameGenitive(at: month))"
    }

    // Короткая подпись: «5 Января» (без дня недели)
    static func shortDayLabel(_ date: Date) -> String {
        let today = startOfDay(Date())
        let target = startOfDay(date)

        if isoString(from: target) == isoString(from: today) { return "Сегодня" }
        if isoString(from: target) == isoString(from: addDays(today, 1)) { return "Завтра" }

        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date) - 1
        return "\(day) \(monthNameGenitive(at: month))"
    }


    static func pluralTasks(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "задача" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "задачи" }
        return "задач"
    }
}
