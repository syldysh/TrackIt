//
//  CalendarWidgetView.swift
//  TrackIt
//
//  Раскрывающийся виджет календаря для режима «Список».
//  Показывает полоску недели или полный месяц (при раскрытии).
//

import SwiftUI

struct CalendarWidgetView: View {
    @EnvironmentObject var vm: CalendarViewModel
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedMonthGrid
            } else {
                WeekStripView().environmentObject(vm)
            }
            expandButton
        }
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Expand Button

    private var expandButton: some View {
        Button {
            withAnimation(.smoothSpring) {
                if !isExpanded { vm.syncMonthToSelected() }
                isExpanded.toggle()
            }
        } label: {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Expanded Month Grid

    private var expandedMonthGrid: some View {
        let dc = RuDate.daysInMonth(year: vm.viewYear, month: vm.viewMonth)
        let le = RuDate.firstWeekdayOfMonth(year: vm.viewYear, month: vm.viewMonth)
        let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return VStack(spacing: 0) {
            LazyVGrid(columns: cols, spacing: 0) {
                ForEach(RuDate.shortWeekdays, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)

            LazyVGrid(columns: cols, spacing: 4) {
                ForEach(0..<(le + dc), id: \.self) { index in
                    if index < le {
                        Color.clear.frame(height: 44)
                    } else {
                        let dayNum = index - le + 1
                        let date = RuDate.calendar.date(from: DateComponents(
                            year: vm.viewYear, month: vm.viewMonth + 1, day: dayNum
                        )) ?? RuDate.startOfDay(vm.selectedDate)
                        let ds = RuDate.isoString(from: date)
                        let isSelected = ds == vm.selectedStr
                        let isToday = ds == vm.todayStr
                        let count = vm.tasks(for: date).filter { !$0.isCompleted }.count

                        Button {
                            withAnimation(.snappySpring) { vm.selectDay(date) }
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(dayNum)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : (isToday ? .brandAccent : Color(.label)))
                                if count > 0 {
                                    HStack(spacing: 1.5) {
                                        ForEach(0..<min(count, 3), id: \.self) { _ in
                                            Circle()
                                                .fill(isSelected ? Color.white.opacity(0.7) : .brandAccent)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                isSelected ? Color.brandAccent :
                                (isToday ? Color.brandAccent.opacity(0.12) : Color(.systemGray6))
                            )
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
