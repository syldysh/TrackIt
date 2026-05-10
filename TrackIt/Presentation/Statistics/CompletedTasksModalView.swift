//
//  CompletedTasksModalView.swift
//  TrackIt
//
//  Подробности карточки выполненных задач.
//

import SwiftUI

struct StatisticsCompletedTasksDetailView: View {
    let tasks: [Task]
    let periodTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            summary
            if tasks.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(tasks) { task in
                        CompletedTaskSummaryRow(task: task)
                    }
                }
            }
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(tasks.count) \(RuDate.pluralTasks(tasks.count))")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.label))
            Text("Выполнено \(periodTitle.lowercased()).")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.brandGreen.opacity(0.1))
        .cornerRadius(16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 28))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 64, height: 64)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            Text("Пока нет выполненных задач")
                .font(.system(size: 17, weight: .semibold))
            Text("Выполните задачу, и она появится в этом списке.")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

private struct CompletedTaskSummaryRow: View {
    let task: Task

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.brandGreen)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.label))
                    .lineLimit(2)

                Text(detailText)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var detailText: String {
        guard let date = task.dateScheduled else { return "Без даты" }
        if let time = task.time, !time.isEmpty {
            return "\(RuDate.shortDayLabel(date)) · \(time)"
        }
        return RuDate.shortDayLabel(date)
    }
}
