//
//  CalendarView.swift
//  TrackIt
//
//  Главный экран «Календарь».
//  Переключает 3 режима: Месяц (список), Неделя (сетка), День (таймлайн).
//

import SwiftUI

// MARK: - View Mode

enum CalViewMode: String, CaseIterable {
    case list, week, day

    var label: String {
        switch self {
        case .list: "Месяц"
        case .week: "Неделя"
        case .day:  "День"
        }
    }

    var icon: String {
        switch self {
        case .list: "calendar"
        case .week: "calendar.day.timeline.left"
        case .day:  "square"
        }
    }
}

// MARK: - CalendarView

struct CalendarView: View {
    @EnvironmentObject var vm: CalendarViewModel

    @State private var showViewMenu = false
    @State private var isExpanded = false
    @State private var showCompleted = false
    @State private var weekModalDate: Date? = nil
    @StateObject private var weekModalDragState = ModalDragState()
    @StateObject private var addTaskDragState = ModalDragState(dismissalOffset: UIScreen.main.bounds.height * 1.05)
    @FocusState private var addFocused: Bool

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea(.container)

            VStack(spacing: 0) {
                CalendarHeaderView(showViewMenu: $showViewMenu)
                    .environmentObject(vm)
                switch vm.viewMode {
                case .list: listView
                case .week: WeekGridView(weekModalDate: $weekModalDate).environmentObject(vm)
                case .day:  DayTimelineView(showCompleted: $showCompleted).environmentObject(vm)
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        guard !vm.isSwipingTask else { return }
                        guard weekModalDate == nil else { return }
                        guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                        withAnimation(.smoothSpring) {
                            if value.translation.width > 0 { vm.goToPrev() }
                            else { vm.goToNext() }
                        }
                    }
            )

            // Модальное окно дня в режиме «Неделя»
            if let date = weekModalDate {
                ModalDimBackground(dragState: weekModalDragState, baseOpacity: 0.3) {
                    dismissWeekModal()
                }
                    .transition(.opacity)
                    .zIndex(10)

                WeekDayModal(date: date, dragState: weekModalDragState, onDismiss: dismissWeekModal)
                    .environmentObject(vm)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                    .zIndex(11)
            }

            if showViewMenu {
                CalendarViewMenuOverlay(isPresented: $showViewMenu, weekModalDate: $weekModalDate)
                    .environmentObject(vm)
            }
            CalendarFloatingAddButton(action: openAddTask)

            if vm.addTaskVM.showAddTask {
                ModalDimBackground(dragState: addTaskDragState, baseOpacity: 0.3) {
                    dismissAddTaskFromBackground()
                }
                    .transition(.opacity)
                    .zIndex(19)
            }

            if vm.addTaskVM.showAddTask {
                AddTaskOverlay(
                    formVM: vm.addTaskVM,
                    addFocused: $addFocused,
                    dragState: addTaskDragState,
                    onDismiss: finishAddTaskDismiss,
                    onBackgroundTap: dismissAddTaskFromBackground
                )
                    .environmentObject(vm)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
                    .zIndex(20)
            }
        }
        .background(TabBarHider(hide: vm.addTaskVM.showAddTask))
        .onChange(of: weekModalDate != nil) { _, isPresented in
            if isPresented { weekModalDragState.reset() }
        }
        .onChange(of: vm.addTaskVM.showAddTask) { _, isPresented in
            if isPresented { addTaskDragState.reset() }
        }
    }

    // MARK: - List View

    private var listView: some View {
        VStack(spacing: 0) {
            CalendarWidgetView(isExpanded: $isExpanded).environmentObject(vm)
            CalendarDayLabelView(selectedDate: vm.selectedDate, todayString: vm.todayStr)
            dayTaskList
        }
    }

    private var dayTaskList: some View {
        let active = vm.sortedActiveTasks(for: vm.selectedDate)
        let completed = vm.completedTasks(for: vm.selectedDate)
        let hasTasks = !active.isEmpty || !completed.isEmpty

        return ZStack(alignment: .top) {
            if hasTasks {
                taskScrollView(active: active, completed: completed)
                    .transition(.identity)
            } else {
                CalendarEmptyDayPlaceholder()
                    .padding(.top, emptyStateCalendarCompensation)
                    .transition(.identity)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func taskScrollView(active: [Task], completed: [Task]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(active) { task in
                    taskRow(task)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            if !completed.isEmpty {
                completedSection(completed)
            }
            Spacer().frame(height: 100)
        }
    }

    private var emptyStateCalendarCompensation: CGFloat {
        guard isExpanded else { return 0 }
        let dayCount = RuDate.daysInMonth(year: vm.viewYear, month: vm.viewMonth)
        let leadingEmptySlots = RuDate.firstWeekdayOfMonth(year: vm.viewYear, month: vm.viewMonth)
        let rowCount = (leadingEmptySlots + dayCount + 6) / 7
        let missingRows = max(0, 6 - rowCount)
        return CGFloat(missingRows) * 48
    }

    private func taskRow(_ task: Task) -> some View {
        TaskRowView(
            task: task,
            onToggle: { vm.toggle(task) },
            onPin: { vm.pin(task) },
            onDelete: { vm.delete(task) },
            onEdit: { vm.addTaskVM.prepareEditTask(task) },
            onSwipeChanged: { vm.isSwipingTask = $0 }
        )
    }

    private func completedSection(_ tasks: [Task]) -> some View {
        VStack(spacing: 0) {
            Button { withAnimation(.smoothSpring) { showCompleted.toggle() } } label: {
                HStack {
                    Text("Выполнено — \(tasks.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                    Spacer()
                    Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            if showCompleted {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        taskRow(task)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func openAddTask() {
        addTaskDragState.reset()
        withAnimation(.sheetSpring) {
            vm.addTaskVM.prepareAddTask(selectedDate: vm.selectedDate)
        }
    }

    private func dismissWeekModal() {
        withAnimation(.sheetSpring) { weekModalDate = nil }
    }

    private func dismissAddTask() {
        addFocused = false
        addTaskDragState.dismiss(onDismiss: finishAddTaskDismiss)
    }

    private func finishAddTaskDismiss() {
        vm.addTaskVM.hideForm()
        DispatchQueue.main.asyncAfter(deadline: .now() + ModalDismissalTiming.cleanupDelay) {
            guard !vm.addTaskVM.showAddTask else { return }
            vm.addTaskVM.clearFormState()
        }
    }

    private func dismissAddTaskFromBackground() {
        addFocused = false
        DispatchQueue.main.async {
            dismissAddTask()
        }
    }
}
