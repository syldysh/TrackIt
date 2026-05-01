import SwiftUI

struct CompletedTasksModalView: View {
    let tasks: [Task]
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            dragArea
            Divider()
            content
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .offset(y: dragState.offset)
    }

    private var dragArea: some View {
        ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
            header
        }
    }

    private var header: some View {
        HStack {
            Text("Выполненные задачи")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Text("\(tasks.count) \(RuDate.pluralTasks(tasks.count))")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var content: some View {
        if tasks.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(tasks) { task in
                        CompletedTaskSummaryRow(task: task)
                    }
                }
                .padding(16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 26))
                        .foregroundColor(Color(.systemGray3))
                )
            Text("Пока нет выполненных задач")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.label))
            Text("Завершите задачу, и она появится здесь.")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
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
