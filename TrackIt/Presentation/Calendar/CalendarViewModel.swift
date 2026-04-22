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

    var headerMonthYear: String {
        let cal = RuDate.calendar
        switch viewMode {
        case .list:
            return "\(RuDate.monthNameNominative(at: viewMonth)) \(viewYear)"
        case .week:
            let d = weekDays.first ?? selectedDate
            let m = cal.component(.month, from: d) - 1
            let y = cal.component(.year, from: d)
            return "\(RuDate.monthNameNominative(at: m)) \(y)"
        case .day:
            let m = cal.component(.month, from: selectedDate) - 1
            let y = cal.component(.year, from: selectedDate)
            return "\(RuDate.monthNameNominative(at: m)) \(y)"
        }
    }

    // MARK: - Init

    init(repository: any TaskRepositoryProtocol) {
        self.repository = repository

        let today = RuDate.startOfDay(Date())
        self.selectedDate = today
        self.weekStart = RuDate.weekStart(for: today)
        self.viewYear = RuDate.calendar.component(.year, from: today)
        self.viewMonth = RuDate.calendar.component(.month, from: today) - 1

        let addVM = AddTaskViewModel(repository: repository)
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

    func toggle(_ task: Task) { repository.toggle(task) }
    func pin(_ task: Task) { repository.pin(task) }
    func delete(_ task: Task) { repository.delete(task) }
    func setTime(_ time: String, for task: Task) { repository.setTime(time, for: task) }

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
        if let d = RuDate.calendar.date(from: DateComponents(year: viewYear, month: viewMonth + 1, day: 1)) {
            selectedDate = RuDate.startOfDay(d)
            weekStart = RuDate.weekStart(for: d)
        }
    }

    func syncMonthToSelected() {
        viewYear = RuDate.calendar.component(.year, from: selectedDate)
        viewMonth = RuDate.calendar.component(.month, from: selectedDate) - 1
    }
}
