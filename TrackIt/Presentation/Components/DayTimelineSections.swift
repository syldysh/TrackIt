//
//  DayTimelineSections.swift
//  TrackIt
//
//  Небольшие UI-блоки для дневного таймлайна.
//  Здесь лежит только верстка секций, а жесты и действия остаются в DayTimelineContent.
//

import SwiftUI

struct DayTimelineUntimedSection<RowContent: View>: View {
    let tasks: [Task]
    let horizontalPadding: CGFloat
    let sectionID: String
    let rowContent: (Task) -> RowContent

    var body: some View {
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("БЕЗ ВРЕМЕНИ")
                    .sectionHeaderStyle()
                ForEach(tasks) { task in
                    rowContent(task)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 4)
            .id(sectionID)
        }
    }
}

struct DayTimelineHourGridView: View {
    let hourHeight: CGFloat
    let idPrefix: String
    let onLongPressChanged: (CGFloat) -> Void
    let onLongPressEnded: (CGFloat) -> Void
    let onLongPressCancelled: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    Text(String(format: "%02d:00", hour))
                        .font(.system(size: isCompact ? 10 : 11, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(width: isCompact ? 32 : 36, alignment: .trailing)
                        .padding(.trailing, isCompact ? 6 : 8)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(.separator).opacity(0.3))
                            .frame(height: 0.5)
                        Spacer(minLength: 0)
                    }
                }
                .frame(height: hourHeight)
                .id("\(idPrefix)_hour_\(hour)")
                .contentShape(Rectangle())
            }
        }
        .contentShape(Rectangle())
        .overlay {
            DayTimelineLongPressOverlay(
                minimumDuration: Constants.longPressDuration,
                onBegan: onLongPressChanged,
                onEnded: onLongPressEnded,
                onCancelled: onLongPressCancelled
            )
        }
    }

    private var isCompact: Bool {
        hourHeight < 60
    }

    private enum Constants {
        static let longPressDuration: TimeInterval = 0.45
    }
}

struct DayTimelinePositionedTaskBlock<ActionsContent: View>: View {
    let task: Task
    let time: String
    let duration: Int
    let blockHeight: CGFloat
    let topOffset: CGFloat
    let isCompact: Bool
    let isDragging: Bool
    let labelWidth: CGFloat
    let showsActions: Bool
    let timeTooltip: String?
    let actionsContent: () -> ActionsContent

    var body: some View {
        ZStack(alignment: .topLeading) {
            DayTimelineTaskBlockView(
                task: task,
                time: time,
                duration: duration,
                height: blockHeight,
                isCompact: isCompact
            )
            if let timeTooltip {
                DayTimelineTimeTooltipView(text: timeTooltip, isCompact: isCompact)
                    .offset(x: isCompact ? 8 : 10, y: tooltipYOffset)
                    .transition(.scale(scale: 0.96, anchor: .bottomLeading).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showsActions {
                actionsContent()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.leading, labelWidth)
        .padding(.trailing, 4)
        .offset(y: topOffset)
        .scaleEffect(isDragging ? 1.03 : 1.0, anchor: .topLeading)
        .shadow(color: isDragging ? .black.opacity(0.2) : .clear, radius: 8, y: 4)
        .zIndex(zIndex)
        .animation(.dragFollow, value: isDragging)
    }

    private var zIndex: Double {
        isDragging ? 10 : (showsActions ? 5 : 0)
    }

    private var tooltipYOffset: CGFloat {
        isCompact ? -18 : -20
    }
}

struct DayTimelineNowLineView: View {
    let date: Date
    let todayString: String
    let hourHeight: CGFloat
    let labelWidth: CGFloat

    var body: some View {
        if RuDate.isoString(from: date) == todayString {
            HStack(spacing: 0) {
                Circle()
                    .fill(Color.red)
                    .frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
                Rectangle()
                    .fill(Color.red)
                    .frame(height: isCompact ? 1 : 1.5)
            }
            .padding(.leading, labelWidth - (isCompact ? 3 : 4))
            .offset(y: topOffset)
        }
    }

    private var topOffset: CGFloat {
        let now = Date()
        let hour = RuDate.calendar.component(.hour, from: now)
        let minute = RuDate.calendar.component(.minute, from: now)
        return CGFloat(hour) * hourHeight + CGFloat(minute) / 60.0 * hourHeight
    }

    private var isCompact: Bool {
        hourHeight < 60
    }
}

struct DayTimelineCompletedSection<RowContent: View>: View {
    let tasks: [Task]
    @Binding var showCompleted: Bool
    let hourHeight: CGFloat
    let horizontalPadding: CGFloat
    let rowContent: (Task) -> RowContent

    var body: some View {
        if !tasks.isEmpty {
            Button { withAnimation(.smoothSpring) { showCompleted.toggle() } } label: {
                HStack {
                    Text("Выполнено — \(tasks.count)")
                        .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                    Spacer()
                    Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                        .font(.system(size: isCompact ? 12 : 13))
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding(.horizontal, isCompact ? 16 : 20)
                .padding(.vertical, isCompact ? 8 : 10)
            }
            if showCompleted {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        rowContent(task)
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var isCompact: Bool {
        hourHeight < 60
    }
}
