//
//  DayTimelineContent.swift
//  TrackIt
//
//  Общий компонент для DayTimelineView и WeekDayModal.
//  Убирает ~200 строк дублирования между двумя файлами.
//  Параметры hourHeight и labelWidth контролируют плотность отображения.
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

    // Перетаскивание задачи
    @State private var draggingTaskID: UUID? = nil
    @State private var dragYOffset: CGFloat = 0
    // Кнопки действий (долгое нажатие без движения)
    @State private var menuTaskID: UUID? = nil

    // MARK: - Данные дня

    private var dayTasks: [Task] { vm.tasks(for: date) }

    private var untimedTasks: [Task] {
        dayTasks.filter { !$0.isCompleted && ($0.time ?? "").isEmpty }
    }

    private var timedTasks: [Task] {
        dayTasks.filter { !$0.isCompleted && !($0.time ?? "").isEmpty }
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

    @ViewBuilder
    private var untimedSection: some View {
        if !untimedTasks.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("БЕЗ ВРЕМЕНИ")
                    .sectionHeaderStyle()
                ForEach(untimedTasks) { task in
                    taskRow(task)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 4)
            .id("\(idPrefix)_untimed")
        }
    }

    // MARK: - Сетка 0–23

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { h in
                HStack(alignment: .top, spacing: 0) {
                    Text(String(format: "%02d:00", h))
                        .font(.system(size: hourHeight >= 60 ? 11 : 10, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(width: hourHeight >= 60 ? 36 : 32, alignment: .trailing)
                        .padding(.trailing, hourHeight >= 60 ? 8 : 6)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(.separator).opacity(0.3))
                            .frame(height: 0.5)
                        Spacer(minLength: 0)
                    }
                }
                .frame(height: hourHeight)
                .id("\(idPrefix)_hour_\(h)")
                .contentShape(Rectangle())
                .onTapGesture {
                    if menuTaskID != nil {
                        withAnimation(.snappySpring) { menuTaskID = nil }
                    } else {
                        withAnimation(.sheetSpring) {
                            vm.addTaskVM.prepareAddTaskAt(hour: h, minute: 0, date: date)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Блоки задач

    private var taskBlocks: some View {
        ForEach(timedTasks) { task in
            if let time = task.time, let (h, m) = parseTime(time) {
                let top = CGFloat(h) * hourHeight + CGFloat(m) / 60.0 * hourHeight
                let dur = task.duration > 0 ? Int(task.duration) : 30
                let minBlockH: CGFloat = hourHeight >= 60 ? 28 : 22
                let blockH = max(CGFloat(dur) / 60.0 * hourHeight, minBlockH)
                let isDragging = draggingTaskID == task.id

                ZStack(alignment: .topTrailing) {
                    taskBlock(task: task, time: time, height: blockH)
                    if menuTaskID == task.id {
                        actionButtons(for: task)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.leading, labelWidth)
                .padding(.trailing, 4)
                .offset(y: top + (isDragging ? dragYOffset : 0))
                .scaleEffect(isDragging ? 1.04 : 1.0)
                .shadow(color: isDragging ? .black.opacity(0.2) : .clear, radius: 8, y: 4)
                .zIndex(isDragging ? 10 : (menuTaskID == task.id ? 5 : 0))
                .animation(.dragFollow, value: isDragging)
                .onTapGesture {
                    if menuTaskID != nil {
                        withAnimation(.snappySpring) { menuTaskID = nil }
                    } else {
                        withAnimation(.sheetSpring) { vm.addTaskVM.prepareEditTask(task) }
                    }
                }
                .gesture(moveGesture(task: task, origH: h, origM: m))
            }
        }
    }

    private func taskBlock(task: Task, time: String, height: CGFloat) -> some View {
        let isCompact = hourHeight < 60
        return VStack(alignment: .leading, spacing: isCompact ? 1 : 2) {
            Text(task.title)
                .font(.system(size: isCompact ? 12 : 13, weight: .semibold))
                .lineLimit(height > (isCompact ? 32 : 40) ? 2 : 1)
            if height > (isCompact ? 28 : 36) {
                Text(timeRange(time: time, duration: Int(task.duration)))
                    .font(.system(size: isCompact ? 10 : 11))
                    .foregroundColor(Color(.label).opacity(0.6))
            }
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 4 : 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(Color.taskBlock)
        .cornerRadius(isCompact ? 8 : 10)
        .contentShape(Rectangle())
    }

    // MARK: - Перетаскивание

    private func moveGesture(task: Task, origH: Int, origM: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                if case .second(true, let drag) = value, let drag = drag {
                    if abs(drag.translation.height) > 5 {
                        if menuTaskID != nil { withAnimation(.snappySpring) { menuTaskID = nil } }
                        draggingTaskID = task.id
                        dragYOffset = drag.translation.height
                    }
                }
            }
            .onEnded { value in
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
        return HStack(spacing: 6) {
            Button {
                vm.toggle(task)
                withAnimation(.snappySpring) { menuTaskID = nil }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
            }
            Button {
                vm.delete(task)
                withAnimation(.snappySpring) { menuTaskID = nil }
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
            }
        }
        .padding(isCompact ? 5 : 6)
        .background(.ultraThinMaterial)
        .cornerRadius(isCompact ? 14 : 16)
        .offset(y: isCompact ? -30 : -36)
        .padding(.trailing, 4)
    }

    // MARK: - Линия «сейчас»

    @ViewBuilder
    private var nowLine: some View {
        if RuDate.isoString(from: date) == vm.todayStr {
            let now = Date()
            let h = RuDate.calendar.component(.hour, from: now)
            let m = RuDate.calendar.component(.minute, from: now)
            let top = CGFloat(h) * hourHeight + CGFloat(m) / 60.0 * hourHeight
            let isCompact = hourHeight < 60

            HStack(spacing: 0) {
                Circle().fill(Color.red).frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
                Rectangle().fill(Color.red).frame(height: isCompact ? 1 : 1.5)
            }
            .padding(.leading, labelWidth - (isCompact ? 3 : 4))
            .offset(y: top)
        }
    }

    // MARK: - Выполненные

    @ViewBuilder
    private var completedSection: some View {
        let completed = dayTasks.filter { $0.isCompleted }
        let isCompact = hourHeight < 60
        if !completed.isEmpty {
            Button { withAnimation(.smoothSpring) { showCompleted.toggle() } } label: {
                HStack {
                    Text("Выполнено — \(completed.count)")
                        .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                    Spacer()
                    Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                        .font(.system(size: isCompact ? 12 : 13))
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding(.horizontal, isCompact ? 16 : 20)
                .padding(.vertical, isCompact ? 8 : 10)
            }
            if showCompleted {
                VStack(spacing: 0) {
                    ForEach(completed) { task in taskRow(task) }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    // MARK: - Хелперы

    private func taskRow(_ task: Task) -> some View {
        TaskRowView(
            task: task,
            onToggle: { vm.toggle(task) },
            onPin: { vm.pin(task) },
            onDelete: { vm.delete(task) },
            onEdit: { vm.addTaskVM.prepareEditTask(task) }
        )
    }

    private func parseTime(_ time: String) -> (Int, Int)? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard let h = parts[safe: 0], let m = parts[safe: 1] else { return nil }
        return (h, m)
    }

    private func timeRange(time: String, duration: Int) -> String {
        let dur = duration > 0 ? duration : 30
        guard let (h, m) = parseTime(time) else { return time }
        let endTotal = h * 60 + m + dur
        let endH = (endTotal / 60) % 24
        let endM = endTotal % 60
        return "\(time) – \(String(format: "%02d:%02d", endH, endM))"
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
