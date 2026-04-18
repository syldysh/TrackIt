//
//  WeekStripView.swift
//  TrackIt
//
//  Горизонтальная полоска дней недели с навигацией.
//  Используется в режимах «Список» и «День».
//

import SwiftUI

struct WeekStripView: View {
    @EnvironmentObject var vm: CalendarViewModel

    // Показывать фон (для режима «День»)
    var showBackground = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(vm.weekDays.enumerated()), id: \.offset) { i, day in
                dayCell(index: i, day: day)
            }
        }
        .padding(.horizontal, 8)
        .if(showBackground) {
            $0.padding(.vertical, 4)
              .background(Color(.systemBackground))
        }
    }

    // MARK: - Day Cell

    private func dayCell(index i: Int, day: Date) -> some View {
        let ds = RuDate.isoString(from: day)
        let isSelected = ds == vm.selectedStr
        let isToday = ds == vm.todayStr
        let taskCount = vm.tasks(for: day).filter { !$0.isCompleted }.count

        return Button {
            withAnimation(.snappySpring) { vm.selectDay(day) }
        } label: {
            VStack(spacing: 3) {
                Text(RuDate.shortWeekday(at: i))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(.secondaryLabel))

                Text("\(RuDate.calendar.component(.day, from: day))")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(dayNumberColor(isSelected: isSelected, isToday: isToday))

                dotIndicator(count: taskCount, isSelected: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isSelected ? Color.brandAccent : Color.clear)
            .cornerRadius(12)
        }
    }

    // MARK: - Helpers

    private func dayNumberColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .brandAccent }
        return Color(.label)
    }

    @ViewBuilder
    private func dotIndicator(count: Int, isSelected: Bool) -> some View {
        if count > 0 {
            HStack(spacing: 2) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.7) : .brandAccent)
                        .frame(width: 5, height: 5)
                }
            }
        } else {
            Color.clear.frame(height: 5)
        }
    }

}

// MARK: - Conditional Modifier

private extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}
