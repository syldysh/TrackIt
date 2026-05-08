//
//  DayTimelineContent.swift
//  TrackIt
//
//  Общий компонент для DayTimelineView и WeekDayModal.
//  Параметры hourHeight и labelWidth контролируют плотность отображения.
//
//

import SwiftUI

struct DayTimelineContent: View {
    @EnvironmentObject var vm: CalendarViewModel

    let date: Date
    var hourHeight: CGFloat = 60
    var labelWidth: CGFloat = 44
    var horizontalPadding: CGFloat = 16
    // Префикс для scroll-anchor ID (чтобы DayTimelineView и WeekDayModal не конфликтовали)
    var idPrefix: String = "day"

    @Binding var showCompleted: Bool
    @State private var menuTaskID: UUID? = nil

    // MARK: - Данные дня

    private var dayTasks: [Task] { vm.tasks(for: date) }

    private var untimedTasks: [Task] {
        dayTasks.filter { !$0.isCompleted && ($0.time ?? "").isEmpty }
    }

    private var timedTasks: [Task] {
        dayTasks.filter { !$0.isCompleted && !($0.time ?? "").isEmpty }
    }

    private var completedTasks: [Task] {
        dayTasks.filter { $0.isCompleted }
    }

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                untimedSection
                hourGrid
                    .overlay(alignment: .topLeading) { taskBlocks }
                    .overlay(alignment: .topLeading) { nowLine }
                    .padding(.horizontal, horizontalPadding)
                completedSection
                Spacer().frame(height: 100)
            }
            .onAppear { scrollToRelevant(proxy) }
            .onChange(of: date) { _, _ in scrollToRelevant(proxy) }
        }
    }

    // MARK: - Без времени

    private var untimedSection: some View {
        DayTimelineUntimedSection(
            tasks: untimedTasks,
            horizontalPadding: horizontalPadding,
            sectionID: "\(idPrefix)_untimed"
        ) { task in
            taskRow(task)
        }
    }

    // MARK: - Сетка 0–23

    private var hourGrid: some View {
        DayTimelineHourGridView(
            hourHeight: hourHeight,
            idPrefix: idPrefix,
            onHourTap: handleHourTap
        )
    }

    // MARK: - Блоки задач

    private var taskBlocks: some View {
        DayTimelineTaskBlocksOverlay(
            tasks: timedTasks,
            hourHeight: hourHeight,
            labelWidth: labelWidth,
            menuTaskID: $menuTaskID
        )
    }

    // MARK: - Линия «сейчас»

    @ViewBuilder
    private var nowLine: some View {
        DayTimelineNowLineView(
            date: date,
            todayString: vm.todayStr,
            hourHeight: hourHeight,
            labelWidth: labelWidth
        )
    }

    // MARK: - Выполненные

    private var completedSection: some View {
        DayTimelineCompletedSection(
            tasks: completedTasks,
            showCompleted: $showCompleted,
            hourHeight: hourHeight,
            horizontalPadding: horizontalPadding
        ) { task in
            taskRow(task)
        }
    }

    // MARK: - Хелперы

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

    private func handleHourTap(_ hour: Int) {
        if menuTaskID != nil {
            withAnimation(.snappySpring) { menuTaskID = nil }
        } else {
            withAnimation(.sheetSpring) {
                vm.addTaskVM.prepareAddTaskAt(hour: hour, minute: 0, date: date)
            }
        }
    }

    private func scrollToRelevant(_ proxy: ScrollViewProxy) {
        if !untimedTasks.isEmpty {
            proxy.scrollTo("\(idPrefix)_untimed", anchor: .top)
            return
        }
        guard !timedTasks.isEmpty else {
            proxy.scrollTo("\(idPrefix)_hour_8", anchor: .top)
            return
        }
        var hourCounts = [Int: Int]()
        for task in timedTasks {
            if let time = task.time, let parsedTime = DayTimelineTime.parse(time) {
                hourCounts[parsedTime.hour, default: 0] += 1
            }
        }
        let bestHour = hourCounts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .first?.key ?? 8
        proxy.scrollTo("\(idPrefix)_hour_\(max(bestHour - 1, 0))", anchor: .top)
    }
}
