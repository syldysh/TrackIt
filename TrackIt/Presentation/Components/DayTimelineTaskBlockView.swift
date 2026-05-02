//
//  DayTimelineTaskBlockView.swift
//  TrackIt
//
//  Карточка задачи внутри дневного таймлайна.
//  Отвечает только за внешний вид блока и кнопок быстрых действий.
//

import SwiftUI

struct DayTimelineTaskBlockView: View {
    let task: Task
    let time: String
    let duration: Int
    let height: CGFloat
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 1 : 2) {
            Text(task.title)
                .font(.system(size: isCompact ? 12 : 13, weight: .semibold))
                .lineLimit(height > (isCompact ? 32 : 40) ? 2 : 1)
            if height > (isCompact ? 28 : 36) {
                Text(timeRange)
                    .font(.system(size: isCompact ? 10 : 11))
                    .foregroundColor(Color(.label).opacity(0.6))
            }
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 4 : 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(Color.taskBlock)
        .cornerRadius(isCompact ? 8 : 10)
        .contentShape(Rectangle())
    }

    private var timeRange: String {
        let dur = duration > 0 ? duration : 30
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard let h = parts[safe: 0], let m = parts[safe: 1] else { return time }
        let endTotal = h * 60 + m + dur
        let endH = (endTotal / 60) % 24
        let endM = endTotal % 60
        return "\(time) – \(String(format: "%02d:%02d", endH, endM))"
    }
}

struct DayTimelineActionButtons: View {
    let isCompact: Bool
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
            }
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
            }
        }
        .padding(isCompact ? 5 : 6)
        .background(.ultraThinMaterial)
        .cornerRadius(isCompact ? 14 : 16)
        .offset(y: isCompact ? -30 : -36)
        .padding(.trailing, 4)
    }
}
