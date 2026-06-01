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
    @GestureState(resetTransaction: Transaction(animation: Constants.Gesture.animation)) private var dragTranslation: CGFloat = 0

    var body: some View {
        let layout = currentLayout

        VStack(spacing: 0) {
            monthGrid(gridYOffset: layout.gridYOffset)
                .frame(height: layout.contentHeight, alignment: .top)
                .clipped()

            expansionHitArea(expansionProgress: layout.expansionProgress)
        }
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .contentShape(Rectangle())
        .simultaneousGesture(calendarExpansionDragGesture)
        .animation(Constants.Gesture.animation, value: isExpanded)
    }

    // MARK: - Expansion Hit Area

    private func expansionHitArea(expansionProgress: CGFloat) -> some View {
        ZStack {
            CalendarExpansionHandleView(progress: expansionProgress)
        }
            .frame(height: Constants.Layout.expansionHitAreaHeight)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                toggleExpanded()
            }
            .accessibilityLabel(isExpanded ? "Свернуть календарь" : "Раскрыть календарь")
            .accessibilityAddTraits(.isButton)
    }

    private func toggleExpanded() {
        withAnimation(Constants.Gesture.animation) {
            setExpanded(!isExpanded)
        }
    }

    // MARK: - Interactive Expansion

    private var calendarExpansionDragGesture: some Gesture {
        DragGesture(minimumDistance: Constants.Gesture.dragMinimumDistance, coordinateSpace: .local)
            .updating($dragTranslation) { value, state, transaction in
                guard hasVerticalIntent(value) else { return }
                transaction.disablesAnimations = true
                state = clampedDragTranslation(value.translation.height)
            }
            .onEnded { value in
                let target = expansionTarget(for: value)
                guard target != isExpanded else { return }

                withAnimation(Constants.Gesture.animation) {
                    setExpanded(target)
                }
            }
    }

    private func setExpanded(_ expanded: Bool) {
        if expanded {
            vm.syncMonthToSelected()
        }
        isExpanded = expanded
    }

    private func hasVerticalIntent(_ value: DragGesture.Value) -> Bool {
        let vertical = abs(value.translation.height)
        let horizontal = abs(value.translation.width)
        return vertical > horizontal
    }

    private func expansionTarget(for value: DragGesture.Value) -> Bool {
        guard hasVerticalIntent(value) else { return isExpanded }

        let intent = verticalIntent(for: value)

        if isExpanded {
            return intent < 0 ? false : true
        } else {
            return intent > 0 ? true : false
        }
    }

    private func verticalIntent(for value: DragGesture.Value) -> CGFloat {
        let actual = value.translation.height
        let predicted = value.predictedEndTranslation.height

        if actual == 0 {
            return predicted
        }

        if actual * predicted > 0, abs(predicted) > abs(actual) {
            return predicted
        }

        return actual
    }

    private var currentLayout: CalendarExpansionLayout {
        let collapsedHeight = Constants.Layout.collapsedContentHeight
        let expandedHeight = expandedContentHeight
        let baseHeight = isExpanded ? expandedHeight : collapsedHeight
        let contentHeight = (baseHeight + dragTranslation).clamped(to: collapsedHeight...expandedHeight)
        let distance = max(expandedHeight - collapsedHeight, 1)
        let progress = ((contentHeight - collapsedHeight) / distance).clamped(to: 0...1)
        let selectedRowOffset = CGFloat(selectedWeekIndex) * Constants.Layout.weekRowHeight
        let gridYOffset = -selectedRowOffset * (1 - progress)

        return CalendarExpansionLayout(
            contentHeight: contentHeight,
            gridYOffset: gridYOffset,
            expansionProgress: progress
        )
    }

    private var expandedContentHeight: CGFloat {
        let rows = monthGridModel.weeks.count
        let rowSpacing = CGFloat(max(rows - 1, 0)) * Constants.Layout.dayRowSpacing
        return Constants.Layout.weekdayHeaderHeight + CGFloat(rows) * Constants.Layout.dayCellHeight + rowSpacing + Constants.Layout.dayRowSpacing
    }

    private var monthGridModel: CalendarMonthGrid {
        CalendarMonthGrid(year: vm.viewYear, month: vm.viewMonth)
    }

    private var selectedWeekIndex: Int {
        monthGridModel.selectedWeekIndex(for: vm.selectedDate)
    }

    private func clampedDragTranslation(_ translation: CGFloat) -> CGFloat {
        let collapsedHeight = Constants.Layout.collapsedContentHeight
        let expandedHeight = expandedContentHeight

        if isExpanded {
            return translation.clamped(to: (collapsedHeight - expandedHeight)...0)
        } else {
            return translation.clamped(to: 0...(expandedHeight - collapsedHeight))
        }
    }

    // MARK: - Month Grid

    private func monthGrid(gridYOffset: CGFloat) -> some View {
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
                ForEach(monthGridModel.days, id: \.self) { date in
                    monthDayButton(for: date)
                }
            }
            .offset(y: gridYOffset)
            .padding(.horizontal, 16)
            .padding(.bottom, Constants.Layout.dayRowSpacing)
        }
    }

    private func monthDayButton(for date: Date) -> some View {
        let dayNum = RuDate.calendar.component(.day, from: date)
        let ds = RuDate.isoString(from: date)
        let isSelected = ds == vm.selectedStr
        let isToday = ds == vm.todayStr
        let count = vm.tasks(for: date).filter { !$0.isCompleted }.count

        return Button {
            withAnimation(.snappySpring) { vm.selectDay(date) }
        } label: {
            ZStack {
                Text("\(dayNum)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dayNumberColor(isSelected: isSelected, isToday: isToday))
                if count > 0 {
                    HStack(spacing: Constants.Layout.taskDotSize / 2) {
                        ForEach(0..<min(count, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? Color.white.opacity(0.7) : .brandAccent)
                                .frame(width: Constants.Layout.taskDotSize, height: Constants.Layout.taskDotSize)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, Constants.Layout.dayRowSpacing * 2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Layout.dayCellHeight)
            .background(dayBackground(isSelected: isSelected, isToday: isToday))
            .cornerRadius(10)
        }
    }

    private func dayNumberColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .brandAccent }
        return Color(.label)
    }

    private func dayBackground(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .brandAccent }
        if isToday { return Color.brandAccent.opacity(0.12) }
        return Color(.systemGray6)
    }

    private enum Constants {
        enum Gesture {
            static let dragMinimumDistance: CGFloat = 6
            static let animation = Animation.interactiveSpring()
        }

        enum Layout {
            static let weekdayHeaderHeight: CGFloat = 29
            static let dayCellHeight: CGFloat = 44
            static let dayRowSpacing: CGFloat = 4
            static let collapsedContentHeight = weekdayHeaderHeight + dayCellHeight + dayRowSpacing
            static let weekRowHeight = dayCellHeight + dayRowSpacing
            static let taskDotSize: CGFloat = 3
            static let expansionHitAreaHeight: CGFloat = 21
        }
    }
}
