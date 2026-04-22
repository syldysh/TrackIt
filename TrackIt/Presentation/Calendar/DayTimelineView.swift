//
//  DayTimelineView.swift
//  TrackIt
//
//  Режим «День»: полоска недели + почасовой таймлайн 0–23.
//  Содержимое таймлайна вынесено в DayTimelineContent.
//

import SwiftUI

struct DayTimelineView: View {
    @EnvironmentObject var vm: CalendarViewModel
    @Binding var showCompleted: Bool

    var body: some View {
        VStack(spacing: 0) {
            WeekStripView(showBackground: true)
                .environmentObject(vm)

            DayTimelineContent(
                date: vm.selectedDate,
                hourHeight: 60,
                labelWidth: 44,
                horizontalPadding: 16,
                idPrefix: "day",
                showCompleted: $showCompleted
            )
            .environmentObject(vm)
        }
    }
}
