//
//  CalendarViewModel.swift
//  TrackIt
//
//  Тонкий ViewModel экрана «Календарь»: навигация по датам + доступ к задачам.
//  Форм-стейт добавления/редактирования вынесен в AddTaskViewModel.
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {

    // MARK: - Зависимости

    private let repository: any TaskRepositoryProtocol
    private let notificationService: any NotificationServiceProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // Форм-стейт добавления/редактирования задачи
    let addTaskVM: AddTaskViewModel

    // MARK: - Навигация

    @Published var viewMode: CalViewMode = .list
    @Published var selectedDate: Date
    @Published var weekStart: Date
    @Published var viewYear: Int
    @Published var viewMonth: Int

    // Флаг: пользователь свайпает задачу
    var isSwipingTask = false

    // MARK: - Вычисляемые свойства

    var todayStr: String { RuDate.isoString(from: RuDate.startOfDay(Date())) }
    var selectedStr: String { RuDate.isoString(from: selectedDate) }
    var weekDays: [Date] { (0..<7).map { RuDate.addDays(weekStart, $0) } }

    var shouldShowTodayButton: Bool {
        let today = Date()
        guard Calendar.current.isDateInToday(selectedDate) else { return true }

        switch viewMode {
        case .list:
            let currentYear = Calendar.current.component(.year, from: today)
            let currentMonth = Calendar.current.component(.month, from: today) - 1
            return viewYear != currentYear || viewMonth != currentMonth
        case .week:
            let currentWeekStart = RuDate.weekStart(for: today)
            return !Calendar.current.isDate(weekStart, inSameDayAs: currentWeekStart)
        case .day:
            return false
        }
    }

    var headerMonthYear: String {
        switch viewMode {
        case .list:
            return RuDate.monthYearTitle(year: viewYear, month: viewMonth)
        case .week:
            let d = weekDays.first ?? selectedDate
            return RuDate.monthYearTitle(for: d)
        case .day:
            return RuDate.monthYearTitle(for: selectedDate)
        }
    }

    // MARK: - Init

    init(
        repository: any TaskRepositoryProtocol,
        notificationService: any NotificationServiceProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.calendarSyncService = calendarSyncService

        let today = RuDate.startOfDay(Date())
        self.selectedDate = today
        self.weekStart = RuDate.weekStart(for: today)
        self.viewYear = RuDate.calendar.component(.year, from: today)
        self.viewMonth = RuDate.calendar.component(.month, from: today) - 1

        let addVM = AddTaskViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )
        self.addTaskVM = addVM

        // Форвардим изменения из репозитория и формы — чтобы View перерисовывалась.
        repository.changePublisher
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        addVM.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Доступ к задачам

    func tasks(for date: Date) -> [Task] {
        repository.tasks(for: date)
    }

    func sortedActiveTasks(for date: Date) -> [Task] {
        tasks(for: date).filter { !$0.isCompleted }.sorted {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            let t0 = $0.time ?? "", t1 = $1.time ?? ""
            if t0.isEmpty != t1.isEmpty { return !t0.isEmpty }
            return t0 < t1
        }
    }

    func completedTasks(for date: Date) -> [Task] {
        tasks(for: date).filter { $0.isCompleted }
    }

    // MARK: - Действия с задачами

    func toggle(_ task: Task) {
        guard let updated = repository.toggle(task) else { return }
        syncSideEffects(for: updated)
    }

    func pin(_ task: Task) { repository.pin(task) }

    func delete(_ task: Task) {
        calendarSyncService.deleteEvent(for: task)
        notificationService.cancelNotification(for: task.id)
        repository.delete(task)
    }

    func setTime(_ time: String, for task: Task) {
        guard let updated = repository.setTime(time, for: task) else { return }
        syncSideEffects(for: updated)
    }

    private func syncSideEffects(for task: Task) {
        notificationService.syncNotification(for: task)
        calendarSyncService.syncEvent(for: task) { [weak self] eventIdentifier in
            guard task.calendarEventIdentifier != eventIdentifier else { return }
            _ = self?.repository.updateCalendarEventIdentifier(eventIdentifier, for: task.id)
        }
    }

    // MARK: - Навигация по датам

    func selectDay(_ d: Date) {
        selectedDate = RuDate.startOfDay(d)
        weekStart = RuDate.weekStart(for: d)
        if viewMode == .list {
            syncMonthToSelected()
        }
    }

    func goToPrev() {
        switch viewMode {
        case .list: goToPrevMonth()
        case .week: goToPrevWeek()
        case .day:  selectDay(RuDate.addDays(selectedDate, -1))
        }
    }

    func goToNext() {
        switch viewMode {
        case .list: goToNextMonth()
        case .week: goToNextWeek()
        case .day:  selectDay(RuDate.addDays(selectedDate, 1))
        }
    }

    func goToToday() {
        let today = RuDate.startOfDay(Date())
        selectedDate = today
        weekStart = RuDate.weekStart(for: today)
        viewYear = RuDate.calendar.component(.year, from: today)
        viewMonth = RuDate.calendar.component(.month, from: today) - 1
    }

    func goToPrevWeek() {
        weekStart = RuDate.addDays(weekStart, -7)
        selectedDate = RuDate.addDays(selectedDate, -7)
    }

    func goToNextWeek() {
        weekStart = RuDate.addDays(weekStart, 7)
        selectedDate = RuDate.addDays(selectedDate, 7)
    }

    func goToPrevMonth() {
        if viewMonth == 0 { viewMonth = 11; viewYear -= 1 } else { viewMonth -= 1 }
        if viewMode == .list { syncSelectedToMonth() }
    }

    func goToNextMonth() {
        if viewMonth == 11 { viewMonth = 0; viewYear += 1 } else { viewMonth += 1 }
        if viewMode == .list { syncSelectedToMonth() }
    }

    private func syncSelectedToMonth() {
        let currentDay = RuDate.calendar.component(.day, from: selectedDate)
        let daysInNewMonth = RuDate.daysInMonth(year: viewYear, month: viewMonth)
        let targetDay = min(currentDay, daysInNewMonth)
        if let d = RuDate.calendar.date(from: DateComponents(year: viewYear, month: viewMonth + 1, day: targetDay)) {
            selectedDate = RuDate.startOfDay(d)
            weekStart = RuDate.weekStart(for: d)
        }
    }

    func syncMonthToSelected() {
        viewYear = RuDate.calendar.component(.year, from: selectedDate)
        viewMonth = RuDate.calendar.component(.month, from: selectedDate) - 1
    }
}
