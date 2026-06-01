//
//  DayTimelineMetrics.swift
//  TrackIt
//
//  Чистая математика дневного таймлайна: координаты, время, snap и границы дня.
//

import CoreGraphics
import Foundation

struct DayTimelineInterval: Equatable {
    let startMinutes: Int
    let endMinutes: Int

    var durationMinutes: Int {
        endMinutes - startMinutes
    }
}

struct DayTimelineMetrics {
    let hourHeight: CGFloat
    let dayStartHour: Int
    let dayEndHour: Int
    let snapStepMinutes: Int
    let minimumDurationMinutes: Int
    let defaultDurationMinutes: Int

    init(
        hourHeight: CGFloat,
        dayStartHour: Int = Defaults.dayStartHour,
        dayEndHour: Int = Defaults.dayEndHour,
        snapStepMinutes: Int = Defaults.snapStepMinutes,
        minimumDurationMinutes: Int = Defaults.minimumDurationMinutes,
        defaultDurationMinutes: Int = Defaults.defaultDurationMinutes
    ) {
        self.hourHeight = hourHeight
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.snapStepMinutes = max(1, snapStepMinutes)
        self.minimumDurationMinutes = max(1, minimumDurationMinutes)
        self.defaultDurationMinutes = max(self.minimumDurationMinutes, defaultDurationMinutes)
    }

    func minutesFromStart(forY y: CGFloat) -> Int {
        let rawMinutes = Int((y / hourHeight * 60).rounded())
        return rawMinutes.clamped(to: 0...totalMinutes)
    }

    func yPosition(forMinutesFromStart minutes: Int) -> CGFloat {
        CGFloat(minutes.clamped(to: 0...totalMinutes)) / 60 * hourHeight
    }

    func height(forDurationMinutes duration: Int) -> CGFloat {
        CGFloat(clampedDuration(duration)) / 60 * hourHeight
    }

    func durationMinutes(forHeight height: CGFloat) -> Int {
        let rawMinutes = Int((height / hourHeight * 60).rounded())
        return clampedDuration(snappedMinutes(rawMinutes))
    }

    func snappedMinutes(_ minutes: Int) -> Int {
        let snapped = Int((Double(minutes) / Double(snapStepMinutes)).rounded()) * snapStepMinutes
        return snapped.clamped(to: 0...totalMinutes)
    }

    func clampedStartMinutes(_ startMinutes: Int, durationMinutes: Int) -> Int {
        let duration = clampedDuration(durationMinutes)
        let maxStart = max(0, totalMinutes - duration)
        return snappedMinutes(startMinutes).clamped(to: 0...maxStart)
    }

    func clampedInterval(startMinutes: Int, endMinutes: Int) -> DayTimelineInterval {
        let start = snappedMinutes(startMinutes)
        let end = snappedMinutes(endMinutes)
        let duration = clampedDuration(end - start)

        if start + duration <= totalMinutes {
            return DayTimelineInterval(startMinutes: start, endMinutes: start + duration)
        }

        let clampedStart = max(0, totalMinutes - duration)
        return DayTimelineInterval(startMinutes: clampedStart, endMinutes: clampedStart + duration)
    }

    func defaultInterval(forY y: CGFloat) -> DayTimelineInterval {
        let duration = clampedDuration(defaultDurationMinutes)
        let start = clampedStartMinutes(
            snappedMinutes(minutesFromStart(forY: y)),
            durationMinutes: duration
        )
        return DayTimelineInterval(startMinutes: start, endMinutes: start + duration)
    }

    func intervalByMoving(startMinutes: Int, endMinutes: Int, translationY: CGFloat) -> DayTimelineInterval {
        let duration = clampedDuration(endMinutes - startMinutes)
        let movedStart = startMinutes + minutesDelta(forTranslationY: translationY)
        let clampedStart = clampedStartMinutes(movedStart, durationMinutes: duration)
        return DayTimelineInterval(startMinutes: clampedStart, endMinutes: clampedStart + duration)
    }

    func intervalByResizingTop(startMinutes: Int, endMinutes: Int, translationY: CGFloat) -> DayTimelineInterval {
        let snappedEnd = snappedMinutes(endMinutes)
        let movedStart = snappedMinutes(startMinutes + minutesDelta(forTranslationY: translationY))
        let maxStart = max(0, snappedEnd - minimumDurationMinutes)
        let clampedStart = movedStart.clamped(to: 0...maxStart)
        return DayTimelineInterval(startMinutes: clampedStart, endMinutes: snappedEnd)
    }

    func intervalByResizingBottom(startMinutes: Int, endMinutes: Int, translationY: CGFloat) -> DayTimelineInterval {
        let snappedStart = snappedMinutes(startMinutes)
        let movedEnd = snappedMinutes(endMinutes + minutesDelta(forTranslationY: translationY))
        let minEnd = min(totalMinutes, snappedStart + minimumDurationMinutes)
        let clampedEnd = movedEnd.clamped(to: minEnd...totalMinutes)
        return DayTimelineInterval(startMinutes: snappedStart, endMinutes: clampedEnd)
    }

    private var totalMinutes: Int {
        max(minimumDurationMinutes, (dayEndHour - dayStartHour) * 60)
    }

    private func minutesDelta(forTranslationY translationY: CGFloat) -> Int {
        snappedDeltaMinutes(Int((translationY / hourHeight * 60).rounded()))
    }

    private func snappedDeltaMinutes(_ minutes: Int) -> Int {
        Int((Double(minutes) / Double(snapStepMinutes)).rounded()) * snapStepMinutes
    }

    private func clampedDuration(_ duration: Int) -> Int {
        max(minimumDurationMinutes, min(duration, totalMinutes))
    }

    enum Defaults {
        static let dayStartHour = 0
        static let dayEndHour = 24
        static let snapStepMinutes = 15
        static let minimumDurationMinutes = 30
        static let defaultDurationMinutes = 60
    }
}
