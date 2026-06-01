//
//  InboxContentViews.swift
//  TrackIt
//
//  Небольшие UI-блоки экрана «Планировщик».
//

import SwiftUI

struct InboxEmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.brandAccent)
                    .clipShape(Circle())
            }
            Text("Нет задач")
                .font(.system(size: 28, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            (Text("Нажмите + чтобы добавить задачу, а\nзатем запланируйте её с помощью ")
                + Text(Image(systemName: "bolt.fill")).foregroundColor(.orange))
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

struct InboxTaskListView: View {
    let tasks: [Task]
    let onSchedule: (Task) -> Void
    let onDelete: (Task) -> Void
    let onEdit: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ЗАДАЧИ — \(tasks.count)")
                .sectionHeaderStyle()
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(tasks) { task in
                    InboxTaskRow(
                        task: task,
                        onSchedule: { onSchedule(task) },
                        onDelete: { onDelete(task) },
                        onEdit: { onEdit(task) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 100)
    }
}

struct InboxFloatingButtons: View {
    let isVisible: Bool
    let onStartPlanning: () -> Void
    let onAdd: () -> Void

    @ViewBuilder
    var body: some View {
        if isVisible {
            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button(action: onStartPlanning) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.brandOrange)
                                .clipShape(Circle())
                                .shadow(color: .orange.opacity(0.35), radius: 12, y: 6)
                        }
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.brandAccent)
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
