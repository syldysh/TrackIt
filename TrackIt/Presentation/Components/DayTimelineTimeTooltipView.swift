//
//  DayTimelineTimeTooltipView.swift
//  TrackIt
//
//  Подсказка snapped-времени при перетаскивании задачи.
//

import SwiftUI

struct DayTimelineTimeTooltipView: View {
    let text: String
    let isCompact: Bool

    var body: some View {
        Text(text)
            .font(.system(size: isCompact ? 10 : 11, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, isCompact ? 8 : 10)
            .padding(.vertical, isCompact ? 4 : 5)
            .background(Color.black.opacity(0.72))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
            .allowsHitTesting(false)
    }
}
