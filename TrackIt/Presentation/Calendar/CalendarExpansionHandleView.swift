//
//  CalendarExpansionHandleView.swift
//  TrackIt
//
//  Нижний индикатор раскрытия календарного виджета.
//

import SwiftUI

struct CalendarExpansionHandleView: View {
    let progress: CGFloat

    var body: some View {
        HStack(spacing: Constants.segmentSpacing) {
            segment
                .rotationEffect(.degrees(angle), anchor: .trailing)
            segment
                .rotationEffect(.degrees(-angle), anchor: .leading)
        }
        .animation(Constants.animation, value: progress)
    }

    private var angle: Double {
        Constants.angle * (1 - 2 * Double(progress))
    }

    private var segment: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(Color(.systemGray3).opacity(Constants.opacity))
            .frame(width: Constants.segmentWidth, height: Constants.height)
    }

    private enum Constants {
        static let segmentWidth: CGFloat = 17
        static let height: CGFloat = 3
        static let cornerRadius: CGFloat = 1.5
        static let segmentSpacing: CGFloat = -3
        static let angle: Double = 4.5
        static let opacity = 0.78
        static let animation = Animation.interactiveSpring()
    }
}
