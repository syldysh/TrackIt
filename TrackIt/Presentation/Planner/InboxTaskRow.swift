//
//  InboxTaskRow.swift
//  TrackIt
//
//  Строка задачи во «Входящих» со свайп-действием удаления.
//

import SwiftUI

struct InboxTaskRow: View {
    let task: Task
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    private var isSwiping: Bool { offset != 0 }

    var body: some View {
        ZStack {
            swipeBackground
            rowContent
        }
        .clipped()
    }

    // MARK: - Swipe Background

    @ViewBuilder
    private var swipeBackground: some View {
        if isSwiping && offset < 0 {
            HStack(spacing: 6) {
                Spacer()
                Image(systemName: "trash").font(.system(size: 14))
                Text("Удалить").font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.brandRed)
        }
    }

    // MARK: - Row Content

    private var rowContent: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.brandAccent)
                .frame(width: 3, height: 36)
                .padding(.leading, 12)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.label))
                Text("Не запланировано")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .frame(minHeight: 60)
        .background(Color(.systemBackground))
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { v in
                    guard v.translation.width < 0 else { return }
                    withAnimation(.dragFollow) { offset = v.translation.width * 0.4 }
                }
                .onEnded { v in
                    if v.translation.width < -80 {
                        withAnimation(.smoothSpring) { onDelete() }
                        offset = 0
                    } else {
                        withAnimation(.smoothSpring) { offset = 0 }
                    }
                }
        )
    }
}
