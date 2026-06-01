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
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let date: Date
    var hourHeight: CGFloat = 60
    var labelWidth: CGFloat = 44
    var horizontalPadding: CGFloat = 16
    // Префикс для scroll-anchor ID (чтобы DayTimelineView и WeekDayModal не конфликтовали)
    var idPrefix: String = "day"

    @Binding var showCompleted: Bool

    // Перетаскивание задачи
    @State private var draggingTaskID: UUID? = nil
    @State private var dragYOffset: CGFloat = 0
    // Кнопки действий (долгое нажатие без движения)
    @State var menuTaskID: UUID? = nil
    @State var timelineDraft: DayTimelineDraft?

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
                    .overlay(alignment: .topLeading) { timelineDraftBlock }
                    .overlay(alignment: .topLeading) { nowLine }
                    .padding(.horizontal, horizontalPadding)
                completedSection
                Spacer().frame(height: 100)
            }
            .onAppear { scrollToRelevant(proxy) }
            .onChange(of: date) { _, _ in scrollToRelevant(proxy) }
            .onChange(of: vm.addTaskVM.showAddTask) { _, isPresented in
                if !isPresented { clearTimelineDraft() }
            }
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
            onLongPressChanged: showTimelineDraft,
            onLongPressEnded: finishTimelineDraft,
            onLongPressCancelled: clearTimelineDraft
        )
    }

    // MARK: - Блоки задач

    private var taskBlocks: some View {
        ForEach(timedTasks) { task in
            if let time = task.time, let (h, m) = parseTime(time) {
                taskBlock(task, time: time, hour: h, minute: m)
                .gesture(moveGesture(task: task, origH: h, origM: m))
            }
        }
    }

    // MARK: - Перетаскивание

    private func moveGesture(task: Task, origH: Int, origM: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                if case .second(true, let drag) = value, let drag = drag {
                    if abs(drag.translation.height) > 5 {
                        vm.isSwipingTask = true
                        if menuTaskID != nil { withAnimation(.snappySpring) { menuTaskID = nil } }
                        draggingTaskID = task.id
                        dragYOffset = drag.translation.height
                    }
                }
            }
            .onEnded { value in
                vm.isSwipingTask = false
                if draggingTaskID == task.id, abs(dragYOffset) > 10 {
                    let origMin = origH * 60 + origM
                    let delta = Int(dragYOffset / hourHeight * 60)
                    let snapped = ((origMin + delta) / 5 * 5).clamped(to: 0...1435)
                    let newTime = String(format: "%02d:%02d", snapped / 60, snapped % 60)
                    vm.setTime(newTime, for: task)
                } else if draggingTaskID == nil {
                    withAnimation(.snappySpring) {
                        menuTaskID = (menuTaskID == task.id) ? nil : task.id
                    }
                }
                withAnimation(.smoothSpring) {
                    draggingTaskID = nil
                    dragYOffset = 0
                }
            }
    }

    // MARK: - Кнопки действий

    private func actionButtons(for task: Task) -> some View {
        let isCompact = hourHeight < 60
        return DayTimelineActionButtons(
            isCompact: isCompact,
            onComplete: {
                vm.toggle(task)
                withAnimation(.snappySpring) { menuTaskID = nil }
            },
            onDelete: {
                vm.delete(task)
                withAnimation(.snappySpring) { menuTaskID = nil }
            }
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

    private func taskBlock(_ task: Task, time: String, hour: Int, minute: Int) -> some View {
        let isDragging = draggingTaskID == task.id
        return DayTimelinePositionedTaskBlock(
            task: task,
            time: time,
            duration: Int(task.duration),
            blockHeight: blockHeight(for: task),
            topOffset: topOffset(hour: hour, minute: minute),
            isCompact: hourHeight < 60,
            isDragging: isDragging,
            dragYOffset: dragYOffset,
            labelWidth: labelWidth,
            showsActions: menuTaskID == task.id
        ) {
            actionButtons(for: task)
        }
        .onTapGesture {
            handleTaskTap(task)
        }
    }

    private func handleTaskTap(_ task: Task) {
        if menuTaskID != nil {
            withAnimation(.snappySpring) { menuTaskID = nil }
        } else {
            withAnimation(.sheetSpring) { vm.addTaskVM.prepareEditTask(task) }
        }
    }

    private func topOffset(hour: Int, minute: Int) -> CGFloat {
        CGFloat(hour) * hourHeight + CGFloat(minute) / 60.0 * hourHeight
    }

    private func blockHeight(for task: Task) -> CGFloat {
        let duration = task.duration > 0 ? Int(task.duration) : 30
        let minBlockHeight: CGFloat = hourHeight >= 60 ? 28 : 22
        return max(CGFloat(duration) / 60.0 * hourHeight, minBlockHeight)
    }

    private func parseTime(_ time: String) -> (Int, Int)? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard let h = parts[safe: 0], let m = parts[safe: 1] else { return nil }
        return (h, m)
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
            if let time = task.time, let (h, _) = parseTime(time) {
                hourCounts[h, default: 0] += 1
            }
        }
        let bestHour = hourCounts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .first?.key ?? 8
        proxy.scrollTo("\(idPrefix)_hour_\(max(bestHour - 1, 0))", anchor: .top)
    }
}
