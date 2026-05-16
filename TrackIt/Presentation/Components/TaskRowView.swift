//
//  TaskRowView.swift
//  TrackIt
//
//  Строка задачи с чекбоксом, названием, временем и свайп-действиями.
//  Принимает Task (domain-модель) и замыкания — не зависит ни от какого ViewModel.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    var onSwipeChanged: ((Bool) -> Void)? = nil

    @State private var offset: CGFloat = 0
    private var isSwiping: Bool { offset != 0 }

    var body: some View {
        ZStack {
            swipeBackground
            rowContent
        }
        .clipped()
        .padding(.bottom, 8)
    }

    // MARK: - Swipe Background

    @ViewBuilder
    private var swipeBackground: some View {
        if !task.isCompleted && isSwiping {
            if offset > 0 {
                pinBackground
            } else if offset < 0 {
                deleteBackground
            }
        }
    }

    private var pinBackground: some View {
        HStack(spacing: 6) {
            Image(systemName: "pin.fill")
                .font(.system(size: 14))
                .rotationEffect(.degrees(30))
            Text(task.pinned ? "Открепить" : "Закрепить")
                .font(.system(size: 15, weight: .semibold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandYellow)
        .cornerRadius(16)
    }

    private var deleteBackground: some View {
        HStack(spacing: 6) {
            Spacer()
            Text("Удалить")
                .font(.system(size: 15, weight: .semibold))
            Image(systemName: "trash")
                .font(.system(size: 14))
        }
        .foregroundColor(.white)
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandRed)
        .cornerRadius(16)
    }

    // MARK: - Row Content

    private var rowContent: some View {
        TaskListItemView(
            task: task,
            secondaryText: timeText,
            secondaryIcon: timeText == nil ? nil : "clock",
            secondaryIconColor: .brandPurple,
            showsPinnedIndicator: true,
            onTap: onEdit,
            showsLeadingAccessory: true
        ) {
            checkboxButton
        }
        .offset(x: offset)
        .gesture(
            task.isCompleted ? nil :
            DragGesture()
                .onChanged { v in
                    onSwipeChanged?(true)
                    withAnimation(.dragFollow) { offset = v.translation.width }
                }
                .onEnded { v in
                    onSwipeChanged?(false)
                    if v.translation.width < -80 {
                        withAnimation(.smoothSpring) { onDelete() }
                    } else if v.translation.width > 80 {
                        withAnimation(.smoothSpring) { onPin() }
                        withAnimation(.smoothSpring) { offset = 0 }
                    } else {
                        withAnimation(.smoothSpring) { offset = 0 }
                    }
                }
        )
    }

    private var checkboxButton: some View {
        Button { withAnimation(.smoothSpring) { onToggle() } } label: {
            TaskCompletionIndicatorView(isCompleted: task.isCompleted)
        }
    }

    private var timeText: String? {
        guard let time = task.time, !time.isEmpty, !task.isCompleted else { return nil }
        return time
    }
}
