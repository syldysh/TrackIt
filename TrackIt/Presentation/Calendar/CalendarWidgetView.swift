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
            ZStack(alignment: .top) {
                WeekStripView()
                    .environmentObject(vm)
                    .opacity(layout.weekStripOpacity)
                    .allowsHitTesting(!isExpanded)

                expandedMonthGrid
                    .opacity(layout.monthGridOpacity)
                    .allowsHitTesting(isExpanded)
            }
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
            dragHandle(expansionProgress: expansionProgress)
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

        return CalendarExpansionLayout(
            contentHeight: contentHeight,
            expansionProgress: progress,
            monthGridOpacity: Double(progress),
            weekStripOpacity: Double(1 - progress)
        )
    }

    private func dragHandle(expansionProgress: CGFloat) -> some View {
        let progress = Double(expansionProgress)
        let angle = Constants.Layout.dragHandleAngle * (1 - 2 * progress)

        return HStack(spacing: Constants.Layout.dragHandleSegmentSpacing) {
            dragHandleSegment
                .rotationEffect(.degrees(angle), anchor: .trailing)
            dragHandleSegment
                .rotationEffect(.degrees(-angle), anchor: .leading)
        }
        .animation(Constants.Gesture.animation, value: expansionProgress)
    }

    private var dragHandleSegment: some View {
        RoundedRectangle(cornerRadius: Constants.Layout.dragHandleCornerRadius)
            .fill(Color(.systemGray4))
            .frame(
                width: Constants.Layout.dragHandleSegmentWidth,
                height: Constants.Layout.dragHandleHeight
            )
    }

    private var expandedContentHeight: CGFloat {
        let rows = monthRowCount
        let rowSpacing = CGFloat(max(rows - 1, 0)) * Constants.Layout.dayRowSpacing
        return Constants.Layout.weekdayHeaderHeight + CGFloat(rows) * Constants.Layout.dayCellHeight + rowSpacing + Constants.Layout.dayRowSpacing
    }

    private var monthRowCount: Int {
        let dayCount = RuDate.daysInMonth(year: vm.viewYear, month: vm.viewMonth)
        let leadingEmptySlots = RuDate.firstWeekdayOfMonth(year: vm.viewYear, month: vm.viewMonth)
        return max(1, (leadingEmptySlots + dayCount + 6) / 7)
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
                        Color.clear.frame(height: Constants.Layout.dayCellHeight)
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
                            ZStack {
                                Text("\(dayNum)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : (isToday ? .brandAccent : Color(.label)))
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
            .padding(.bottom, Constants.Layout.dayRowSpacing)
        }
    }

    private enum Constants {
        enum Gesture {
            static let dragMinimumDistance: CGFloat = 6
            static let animation = Animation.interactiveSpring()
        }

        enum Layout {
            static let collapsedContentHeight: CGFloat = 62
            static let weekdayHeaderHeight: CGFloat = 29
            static let dayCellHeight: CGFloat = 44
            static let dayRowSpacing: CGFloat = 4
            static let taskDotSize: CGFloat = 3
            static let expansionHitAreaHeight: CGFloat = 21
            static let dragHandleSegmentWidth: CGFloat = 20
            static let dragHandleHeight: CGFloat = 5
            static let dragHandleCornerRadius: CGFloat = 3
            static let dragHandleSegmentSpacing: CGFloat = -4
            static let dragHandleAngle: Double = 7
        }
    }
}

private struct CalendarExpansionLayout {
    let contentHeight: CGFloat
    let expansionProgress: CGFloat
    let monthGridOpacity: Double
    let weekStripOpacity: Double
}
