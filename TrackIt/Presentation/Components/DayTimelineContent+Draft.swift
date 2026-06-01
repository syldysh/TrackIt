//
//  DayTimelineContent+Draft.swift
//  TrackIt
//
//  UI-preview задачи при long press по дневному таймлайну.
//

import SwiftUI

extension DayTimelineContent {
    @ViewBuilder
    var timelineDraftBlock: some View {
        if let timelineDraft, RuDate.calendar.isDate(timelineDraft.date, inSameDayAs: date) {
            let metrics = DayTimelineMetrics(hourHeight: hourHeight)
            DayTimelineDraftBlockView(
                interval: timelineDraft.interval,
                topOffset: metrics.yPosition(forMinutesFromStart: timelineDraft.interval.startMinutes),
                height: metrics.height(forDurationMinutes: timelineDraft.interval.durationMinutes),
                labelWidth: labelWidth,
                isCompact: hourHeight < 60
            )
            .transition(draftTransition)
        }
    }

    func showTimelineDraft(atY y: CGFloat) {
        guard menuTaskID == nil else { return }

        let draft = DayTimelineDraft(
            date: date,
            interval: DayTimelineMetrics(hourHeight: hourHeight).defaultInterval(forY: y)
        )
        guard timelineDraft != draft else { return }

        withAnimation(draftAnimation) {
            timelineDraft = draft
        }
    }

    func finishTimelineDraft(atY y: CGFloat) {
        if menuTaskID != nil {
            withAnimation(.snappySpring) { menuTaskID = nil }
            clearTimelineDraft()
            return
        }

        let interval = timelineDraft?.interval
            ?? DayTimelineMetrics(hourHeight: hourHeight).defaultInterval(forY: y)
        if timelineDraft == nil {
            timelineDraft = DayTimelineDraft(date: date, interval: interval)
        }
        withAnimation(.sheetSpring) {
            vm.addTaskVM.prepareAddTask(on: date, interval: interval)
        }
    }

    func clearTimelineDraft() {
        guard timelineDraft != nil else { return }
        withAnimation(draftAnimation) {
            timelineDraft = nil
        }
    }

    private var draftAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.16) : .snappySpring
    }

    private var draftTransition: AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.98).combined(with: .opacity)
    }
}
