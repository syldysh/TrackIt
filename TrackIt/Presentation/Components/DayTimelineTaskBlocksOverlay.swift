//
//  DayTimelineTaskBlocksOverlay.swift
//  TrackIt
//
//  Timed-задачи поверх сетки дня: позиционирование, long-press drag и action-menu.
//

import SwiftUI

struct DayTimelineTaskBlocksOverlay: View {
    @EnvironmentObject var vm: CalendarViewModel

    let tasks: [Task]
    let hourHeight: CGFloat
    let labelWidth: CGFloat
    @Binding var menuTaskID: UUID?

    @State private var draggingTaskID: UUID? = nil
    @State private var dragYOffset: CGFloat = 0

    var body: some View {
        ForEach(tasks) { task in
            if let time = task.time, let parsedTime = DayTimelineTime.parse(time) {
                taskBlock(
                    task,
                    time: time,
                    hour: parsedTime.hour,
                    minute: parsedTime.minute
                )
                .gesture(moveGesture(task: task, origH: parsedTime.hour, origM: parsedTime.minute))
            }
        }
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

    private func moveGesture(task: Task, origH: Int, origM: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                if case .second(true, let drag) = value, let drag = drag {
                    handleDragChange(drag, task: task)
                }
            }
            .onEnded { _ in
                handleDragEnd(task: task, origH: origH, origM: origM)
            }
    }

    private func handleDragChange(_ drag: DragGesture.Value, task: Task) {
        guard abs(drag.translation.height) > 5 else { return }
        vm.isSwipingTask = true
        if menuTaskID != nil { withAnimation(.snappySpring) { menuTaskID = nil } }
        draggingTaskID = task.id
        dragYOffset = drag.translation.height
    }

    private func handleDragEnd(task: Task, origH: Int, origM: Int) {
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

    private func actionButtons(for task: Task) -> some View {
        DayTimelineActionButtons(
            isCompact: hourHeight < 60,
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
}
