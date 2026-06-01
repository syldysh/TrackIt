//
//  DayTimelineContent+Drag.swift
//  TrackIt
//
//  Интерактивное перемещение сохранённых задач по дневному таймлайну.
//

import SwiftUI

extension DayTimelineContent {
    func moveGesture(task: Task, originalInterval: DayTimelineInterval) -> some Gesture {
        DragGesture(minimumDistance: Constants.dragMinimumDistance)
            .onChanged { value in
                let previewInterval = dragInterval(
                    from: originalInterval,
                    translationY: value.translation.height
                )
                vm.isSwipingTask = true
                if menuTaskID != nil {
                    withAnimation(.snappySpring) { menuTaskID = nil }
                }
                timelineDrag = DayTimelineDragState(
                    taskID: task.id,
                    originalInterval: originalInterval,
                    previewInterval: previewInterval
                )
            }
            .onEnded { value in
                let finalInterval = dragInterval(
                    from: originalInterval,
                    translationY: value.translation.height
                )
                vm.isSwipingTask = false
                if finalInterval != originalInterval {
                    vm.updateTaskInterval(
                        taskID: task.id,
                        date: date,
                        startMinutes: finalInterval.startMinutes,
                        endMinutes: finalInterval.endMinutes
                    )
                }
                withAnimation(.smoothSpring) {
                    timelineDrag = nil
                }
            }
    }

    func menuGesture(task: Task) -> some Gesture {
        LongPressGesture(minimumDuration: Constants.menuLongPressDuration)
            .onEnded { _ in
                guard timelineDrag?.taskID != task.id else { return }
                withAnimation(.snappySpring) {
                    menuTaskID = (menuTaskID == task.id) ? nil : task.id
                }
            }
    }

    func timelineInterval(for task: Task) -> DayTimelineInterval? {
        guard let start = startMinutes(for: task) else { return nil }
        let duration = max(Int(task.duration), DayTimelineMetrics.Defaults.minimumDurationMinutes)
        return DayTimelineMetrics(hourHeight: hourHeight).clampedInterval(
            startMinutes: start,
            endMinutes: start + duration
        )
    }

    func startMinutes(for task: Task) -> Int? {
        guard let time = task.time, !time.isEmpty else { return nil }
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard let hour = parts[safe: 0], let minute = parts[safe: 1] else { return nil }
        return hour * 60 + minute
    }

    func topOffset(for interval: DayTimelineInterval) -> CGFloat {
        DayTimelineMetrics(hourHeight: hourHeight)
            .yPosition(forMinutesFromStart: interval.startMinutes)
    }

    func blockHeight(for interval: DayTimelineInterval) -> CGFloat {
        let minBlockHeight: CGFloat = hourHeight >= 60 ? 28 : 22
        return max(
            DayTimelineMetrics(hourHeight: hourHeight)
                .height(forDurationMinutes: interval.durationMinutes),
            minBlockHeight
        )
    }

    func timeString(from minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    func timeRangeText(for interval: DayTimelineInterval) -> String {
        "\(timeString(from: interval.startMinutes)) – \(timeString(from: interval.endMinutes))"
    }

    private func dragInterval(
        from originalInterval: DayTimelineInterval,
        translationY: CGFloat
    ) -> DayTimelineInterval {
        DayTimelineMetrics(hourHeight: hourHeight).intervalByMoving(
            startMinutes: originalInterval.startMinutes,
            endMinutes: originalInterval.endMinutes,
            translationY: translationY
        )
    }

    private enum Constants {
        static let dragMinimumDistance: CGFloat = 8
        static let menuLongPressDuration: TimeInterval = 0.35
    }
}
