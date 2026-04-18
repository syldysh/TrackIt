//
//  ExpandedDayCard.swift
//  TrackIt
//
//  Раскрывающаяся карточка дня со списком задач.
//  Появляется при тапе на день в режимах «Месяц» и «Неделя».
//

import SwiftUI

struct ExpandedDayCard: View {
    @EnvironmentObject var vm: CalendarViewModel
    let dateStr: String

    private var date: Date { RuDate.date(from: dateStr) }
    private var activeTasks: [Task] { vm.tasks(for: date).filter { !$0.isCompleted } }
    private var completedTasks: [Task] { vm.tasks(for: date).filter { $0.isCompleted } }

    private var title: String {
        dateStr == vm.todayStr ? "Сегодня" : RuDate.dayLabel(date)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .cardStyle()
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            Text("\(activeTasks.count) \(RuDate.pluralTasks(activeTasks.count))")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var content: some View {
        if activeTasks.isEmpty && completedTasks.isEmpty {
            Text("Нет задач на этот день")
                .font(.system(size: 14))
                .foregroundColor(Color(.tertiaryLabel))
                .padding(.vertical, 20)
        } else {
            VStack(spacing: 0) {
                ForEach(activeTasks) { task in
                    taskRow(task)
                }
                ForEach(completedTasks) { task in
                    taskRow(task)
                }
            }
        }
    }

    private func taskRow(_ task: Task) -> some View {
        TaskRowView(
            task: task,
            onToggle: { vm.toggle(task) },
            onPin: { vm.pin(task) },
            onDelete: { vm.delete(task) },
            onEdit: { vm.addTaskVM.prepareEditTask(task) }
        )
    }
}
