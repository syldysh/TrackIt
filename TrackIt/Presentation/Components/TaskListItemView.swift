//
//  TaskListItemView.swift
//  TrackIt
//
//  Общий визуальный слой карточки задачи без экранных действий и жестов.
//

import SwiftUI

struct TaskListItemView<LeadingAccessory: View>: View {
    let task: Task
    let secondaryText: String?
    let secondaryIcon: String?
    let secondaryIconColor: Color
    let showsPinnedIndicator: Bool
    let onTap: () -> Void
    let showsLeadingAccessory: Bool
    @ViewBuilder let leadingAccessory: () -> LeadingAccessory

    var body: some View {
        HStack(spacing: 12) {
            if showsLeadingAccessory {
                leadingAccessory()
            }

            HStack(spacing: 0) {
                titleAndSecondaryText
                Spacer()
                if showsPinnedIndicator && task.pinned && !task.isCompleted {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.brandAccent)
                        .rotationEffect(.degrees(30))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.sheetSpring) { onTap() }
            }
        }
        .frame(minHeight: Layout.minimumRowHeight)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var titleAndSecondaryText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(task.isCompleted ? Color(.tertiaryLabel) : Color(.label))
                .strikethrough(task.isCompleted)
                .lineLimit(1)

            if let secondaryText {
                HStack(spacing: 3) {
                    if let secondaryIcon {
                        Image(systemName: secondaryIcon)
                            .font(.system(size: 10))
                            .foregroundColor(secondaryIconColor)
                    }
                    Text(secondaryText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
    }
}

private enum Layout {
    static let minimumRowHeight: CGFloat = 26
}

struct TaskCompletionIndicatorView: View {
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isCompleted ? Color.brandGreen : Color(.systemGray4),
                    lineWidth: 2
                )
                .frame(width: 26, height: 26)
                .background(isCompleted ? Circle().fill(Color.brandGreen) : nil)
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
