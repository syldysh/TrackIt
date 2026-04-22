//
//  WeekGridView.swift
//  TrackIt
//
//  Режим «Неделя»: мини-календарь месяца + сетка карточек дней (2 колонки).
//  Тап по карточке дня открывает модальное окно с таймлайном.
//

import SwiftUI

struct WeekGridView: View {
    @EnvironmentObject var vm: CalendarViewModel
    @Binding var weekModalDate: Date?

    var body: some View {
        ScrollView {
            miniMonthCalendar
            dayCardsGrid
            Spacer().frame(height: 100)
        }
    }

    // MARK: - Mini Month Calendar

    private var miniMonthCalendar: some View {
        let weekStart = vm.weekDays.first ?? vm.selectedDate
        let weekEnd = vm.weekDays.last ?? weekStart
        let wkY = RuDate.calendar.component(.year, from: weekStart)
        let wkM = RuDate.calendar.component(.month, from: weekStart) - 1
        let dc = RuDate.daysInMonth(year: wkY, month: wkM)
        let le = RuDate.firstWeekdayOfMonth(year: wkY, month: wkM)
        let wkStartStr = RuDate.isoString(from: weekStart)
        let wkEndStr = RuDate.isoString(from: weekEnd)
        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

        return VStack(spacing: 0) {
            LazyVGrid(columns: cols, spacing: 0) {
                ForEach(RuDate.shortWeekdays, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 12)

            LazyVGrid(columns: cols, spacing: 2) {
                ForEach(0..<(le + dc), id: \.self) { index in
                    if index < le {
                        Color.clear.frame(height: 32)
                    } else {
                        let dayNum = index - le + 1
                        let date = RuDate.calendar.date(
                            from: DateComponents(year: wkY, month: wkM + 1, day: dayNum)
                        ) ?? RuDate.startOfDay(vm.selectedDate)
                        let ds = RuDate.isoString(from: date)
                        let inWeek = ds >= wkStartStr && ds <= wkEndStr
                        let isToday = ds == vm.todayStr
                        let taskCount = vm.tasks(for: date).filter { !$0.isCompleted }.count
                        Button {
                            withAnimation(.snappySpring) { vm.selectDay(date) }
                        } label: {
                            VStack(spacing: 1) {
                                Text("\(dayNum)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(isToday ? .brandAccent : Color(.label))
                                miniMonthDots(count: taskCount, inWeek: inWeek)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(inWeek ? Color.brandAccent.opacity(0.12) : Color.clear)
                            .cornerRadius(6)
                            .opacity(inWeek ? 1 : 0.5)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Day Cards Grid

    private var dayCardsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(vm.weekDays.enumerated()), id: \.offset) { i, day in
                dayCard(index: i, day: day)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func dayCard(index i: Int, day: Date) -> some View {
        let ds = RuDate.isoString(from: day)
        let isToday = ds == vm.todayStr
        let isModal = weekModalDate != nil && RuDate.isoString(from: weekModalDate!) == ds
        let activeTasks = vm.sortedActiveTasks(for: day)

        return Button {
            withAnimation(.sheetSpring) {
                vm.selectDay(day)
                weekModalDate = day
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                dayCardHeader(index: i, day: day, isToday: isToday, isSelected: isModal)
                dayCardTaskBars(tasks: activeTasks)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isModal ? Color.brandAccent : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func dayCardHeader(index i: Int, day: Date, isToday: Bool, isSelected: Bool) -> some View {
        HStack(spacing: 4) {
            Text(RuDate.shortWeekday(at: i))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
            if isToday {
                Text("\(RuDate.calendar.component(.day, from: day))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.brandAccent)
                    .clipShape(Circle())
            } else {
                Text("\(RuDate.calendar.component(.day, from: day))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .brandAccent : Color(.label))
            }
        }
    }

    // Полоски задач с названиями (макс. 3, остаток — "+N")
    private func dayCardTaskBars(tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if tasks.isEmpty {
                Text("Нет задач")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.systemGray3))
            } else {
                ForEach(tasks.prefix(3)) { task in
                    HStack(spacing: 0) {
                        Text(task.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(.label))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBlue).opacity(0.15))
                    .cornerRadius(4)
                }
                if tasks.count > 3 {
                    Text("+\(tasks.count - 3)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.top, 1)
                }
            }
        }
    }

    @ViewBuilder
    private func miniMonthDots(count: Int, inWeek: Bool) -> some View {
        if count > 0 {
            HStack(spacing: 1.5) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Circle()
                        .fill(inWeek ? .brandAccent : Color(.systemGray3))
                        .frame(width: 3, height: 3)
                }
            }
            .frame(height: 4)
        } else {
            Color.clear.frame(height: 4)
        }
    }
}
