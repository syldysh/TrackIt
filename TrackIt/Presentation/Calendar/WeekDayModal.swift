//
//  WeekDayModal.swift
//  TrackIt
//
//  Модальное окно дня в режиме «Неделя».
//  Содержимое таймлайна вынесено в DayTimelineContent.
//

import SwiftUI

struct WeekDayModal: View {
    @EnvironmentObject var vm: CalendarViewModel
    let date: Date
    @ObservedObject var dragState: ModalDragState
    var onDismiss: () -> Void = {}

    @State private var showCompleted = false

    private var dateLabel: String {
        RuDate.isoString(from: date) == vm.todayStr ? "Сегодня" : RuDate.dayLabel(date)
    }

    var body: some View {
        VStack(spacing: 0) {
            dragArea
            Divider()

            DayTimelineContent(
                date: date,
                hourHeight: 44,
                labelWidth: 38,
                horizontalPadding: 12,
                idPrefix: "modal",
                showCompleted: $showCompleted
            )
            .environmentObject(vm)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .modalDragOffset(dragState)
    }

    // MARK: - Drag Area

    private var dragArea: some View {
        ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
            header
        }
    }

    // MARK: - Хедер

    private var header: some View {
        let activeTasks = vm.tasks(for: date).filter { !$0.isCompleted }
        return HStack {
            Text(dateLabel)
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Text("\(activeTasks.count) \(RuDate.pluralTasks(activeTasks.count))")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
