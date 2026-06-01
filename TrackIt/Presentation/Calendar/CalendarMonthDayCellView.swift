//
//  CalendarMonthDayCellView.swift
//  TrackIt
//
//  Ячейка даты внутри месячной сетки календаря.
//

import SwiftUI

struct CalendarMonthDayCellView: View {
    let date: Date
    let selectedString: String
    let todayString: String
    let taskCount: Int
    let onSelect: () -> Void

    private var dayNumber: Int {
        RuDate.calendar.component(.day, from: date)
    }

    private var isSelected: Bool {
        RuDate.isoString(from: date) == selectedString
    }

    private var isToday: Bool {
        RuDate.isoString(from: date) == todayString
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                Text("\(dayNumber)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dayNumberColor)
                if taskCount > 0 {
                    dotIndicator
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.height)
            .background(backgroundColor)
            .cornerRadius(Constants.cornerRadius)
        }
    }

    private var dotIndicator: some View {
        HStack(spacing: Constants.taskDotSize / 2) {
            ForEach(0..<min(taskCount, Constants.maxVisibleDots), id: \.self) { _ in
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.7) : .brandAccent)
                    .frame(width: Constants.taskDotSize, height: Constants.taskDotSize)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, Constants.dotBottomPadding)
    }

    private var dayNumberColor: Color {
        if isSelected { return .white }
        if isToday { return .brandAccent }
        return Color(.label)
    }

    private var backgroundColor: Color {
        if isSelected { return .brandAccent }
        if isToday { return Color.brandAccent.opacity(0.12) }
        return Color(.systemGray6)
    }

    private enum Constants {
        static let height: CGFloat = 44
        static let cornerRadius: CGFloat = 10
        static let taskDotSize: CGFloat = 3
        static let maxVisibleDots = 3
        static let dotBottomPadding: CGFloat = 8
    }
}
