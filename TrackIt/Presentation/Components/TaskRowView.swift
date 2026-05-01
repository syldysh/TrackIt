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
        HStack(spacing: 12) {
            checkboxButton
            HStack(spacing: 0) {
                titleAndTime
                Spacer()
                if task.pinned && !task.isCompleted {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.brandAccent)
                        .rotationEffect(.degrees(30))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.sheetSpring) { onEdit() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
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
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? Color.brandGreen : Color(.systemGray4),
                        lineWidth: 2
                    )
                    .frame(width: 26, height: 26)
                    .background(task.isCompleted ? Circle().fill(Color.brandGreen) : nil)
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var titleAndTime: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(task.isCompleted ? Color(.tertiaryLabel) : Color(.label))
                .strikethrough(task.isCompleted)
                .lineLimit(1)
            if let t = task.time, !t.isEmpty, !task.isCompleted {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.brandPurple)
                    Text(t)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
    }
}
