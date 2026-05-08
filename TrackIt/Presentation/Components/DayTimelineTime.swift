//
//  DayTimelineTime.swift
//  TrackIt
//
//  Общие операции со временем для таймлайна дня.
//

import Foundation

enum DayTimelineTime {
    static func parse(_ time: String) -> (hour: Int, minute: Int)? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}
