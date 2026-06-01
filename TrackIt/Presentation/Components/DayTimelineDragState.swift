//
//  DayTimelineDragState.swift
//  TrackIt
//
//  Локальное состояние интерактивного переноса задачи в дневном таймлайне.
//

import Foundation

struct DayTimelineDragState: Equatable {
    let taskID: UUID
    let originalInterval: DayTimelineInterval
    let previewInterval: DayTimelineInterval
}
