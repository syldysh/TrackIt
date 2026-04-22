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
    @FocusState private var addFocused: Bool

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                header
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
                Color.black.opacity(0.3)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.sheetSpring) { weekModalDate = nil }
                    }
                    .transition(.opacity)
                    .zIndex(10)

                WeekDayModal(date: date)
                    .environmentObject(vm)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                    .zIndex(11)
            }

            if showViewMenu { viewMenuOverlay }
            fabButton

            if vm.addTaskVM.showAddTask {
                Color.black.opacity(0.3)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.sheetSpring) { vm.addTaskVM.reset() }
                        addFocused = false
                    }
                    .transition(.opacity)
                    .zIndex(19)
            }

            if vm.addTaskVM.showAddTask {
                AddTaskOverlay(formVM: vm.addTaskVM, addFocused: $addFocused)
                    .environmentObject(vm)
                    .transition(.move(edge: .bottom))
                    .zIndex(20)
            }
        }
        .background(TabBarHider(hide: vm.addTaskVM.showAddTask))
    }

    // MARK: - Header

    private var header: some View {
        Button { withAnimation(.smoothSpring) { showViewMenu.toggle() } } label: {
            HStack(spacing: 6) {
                Text(vm.headerMonthYear)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(.label))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                    .rotationEffect(.degrees(showViewMenu ? 180 : 0))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - View Menu Overlay

    private var viewMenuOverlay: some View {
        ZStack(alignment: .top) {
            Color.clear.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.smoothSpring) { showViewMenu = false } }

            VStack(spacing: 0) {
                ForEach(CalViewMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.smoothSpring) {
                            if mode == .week { vm.syncMonthToSelected() }
                            vm.viewMode = mode
                            weekModalDate = nil
                            showViewMenu = false
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 16))
                                .foregroundColor(vm.viewMode == mode ? .brandAccent : Color(.secondaryLabel))
                                .frame(width: 22)
                            Text(mode.label)
                                .font(.system(size: 16))
                                .foregroundColor(vm.viewMode == mode ? .brandAccent : Color(.label))
                            Spacer()
                            if vm.viewMode == mode {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.brandAccent)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    if mode != .day { Divider().padding(.leading, 50) }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.16), radius: 20, y: 8)
            .frame(width: 220)
            .padding(.top, 48)
        }
        .zIndex(50)
    }

    // MARK: - List View

    private var listView: some View {
        VStack(spacing: 0) {
            CalendarWidgetView(isExpanded: $isExpanded).environmentObject(vm)
            dayLabel
            dayTaskList
        }
    }

    private var dayLabel: some View {
        HStack(spacing: 8) {
            Text(RuDate.dateDayLabel(vm.selectedDate))
                .font(.system(size: 17, weight: .semibold))
            if RuDate.isoString(from: vm.selectedDate) == vm.todayStr {
                Text("сегодня")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandAccent)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var dayTaskList: some View {
        let active = vm.sortedActiveTasks(for: vm.selectedDate)
        let completed = vm.completedTasks(for: vm.selectedDate)

        return ScrollView {
            if active.isEmpty && completed.isEmpty {
                emptyDayPlaceholder
            } else {
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
            }
            Spacer().frame(height: 100)
        }
    }

    private func taskRow(_ task: Task) -> some View {
        TaskRowView(
            task: task,
            onToggle: { vm.toggle(task) },
            onPin: { vm.pin(task) },
            onDelete: { vm.delete(task) },
            onEdit: { vm.addTaskVM.prepareEditTask(task) }
        )
    }

    private var emptyDayPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.systemGray3))
                )
            Text("Нет задач на этот день")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
            Text("Выберите день в календаре")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity)
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

    // MARK: - FAB

    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.sheetSpring) {
                        vm.addTaskVM.prepareAddTask(selectedDate: vm.selectedDate)
                    }
                    addFocused = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.brandAccent)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
