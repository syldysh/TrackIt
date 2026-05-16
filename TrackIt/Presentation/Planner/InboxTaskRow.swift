//
//  InboxTaskRow.swift
//  TrackIt
//
//  Строка задачи во «Входящих» со свайп-действиями планирования и удаления.
//

import SwiftUI

struct InboxTaskRow: View {
    let task: Task
    let onSchedule: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    @State private var offset: CGFloat = 0
    private var isSwiping: Bool { offset != 0 }
    private let actionThreshold: CGFloat = 80

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
        if isSwiping && offset > 0 {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.plus").font(.system(size: 14))
                Text("Запланировать").font(.system(size: 14, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.brandGreen)
            .cornerRadius(16)
        } else if isSwiping && offset < 0 {
            HStack(spacing: 6) {
                Spacer()
                Image(systemName: "trash").font(.system(size: 14))
                Text("Удалить").font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.brandRed)
            .cornerRadius(16)
        }
    }

    // MARK: - Row Content

    private var rowContent: some View {
        TaskListItemView(
            task: task,
            secondaryText: nil,
            secondaryIcon: nil,
            secondaryIconColor: .clear,
            showsPinnedIndicator: false,
            onTap: onEdit,
            showsLeadingAccessory: false
        ) {
            EmptyView()
        }
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { v in
                    guard abs(v.translation.width) > abs(v.translation.height) else { return }
                    withAnimation(.dragFollow) { offset = v.translation.width }
                }
                .onEnded { v in
                    if v.translation.width > actionThreshold {
                        withAnimation(.smoothSpring) { offset = 0 }
                        onSchedule()
                    } else if v.translation.width < -actionThreshold {
                        withAnimation(.smoothSpring) { offset = 0 }
                        onDelete()
                    } else {
                        withAnimation(.smoothSpring) { offset = 0 }
                    }
                }
        )
    }
}
