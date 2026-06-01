//
//  DayTimelineDraftBlockView.swift
//  TrackIt
//
//  Временный preview-блок задачи при создании из дневного таймлайна.
//

import SwiftUI

struct DayTimelineDraft: Equatable {
    let date: Date
    let interval: DayTimelineInterval
}

struct DayTimelineDraftBlockView: View {
    let interval: DayTimelineInterval
    let topOffset: CGFloat
    let height: CGFloat
    let labelWidth: CGFloat
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 1 : 2) {
            Text("Новая задача")
                .font(.system(size: isCompact ? 12 : 13, weight: .semibold))
                .lineLimit(1)
            if height > (isCompact ? 28 : 36) {
                Text(timeRange)
                    .font(.system(size: isCompact ? 10 : 11))
                    .foregroundColor(Color.brandAccent.opacity(0.72))
            }
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 4 : 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(Color.brandAccent.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 8 : 10)
                .stroke(Color.brandAccent.opacity(0.42), lineWidth: 1)
        )
        .foregroundColor(.brandAccent)
        .cornerRadius(isCompact ? 8 : 10)
        .padding(.leading, labelWidth)
        .padding(.trailing, 4)
        .offset(y: topOffset)
        .allowsHitTesting(false)
        .zIndex(6)
    }

    private var timeRange: String {
        "\(timeString(interval.startMinutes)) – \(timeString(interval.endMinutes))"
    }

    private func timeString(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }
}
