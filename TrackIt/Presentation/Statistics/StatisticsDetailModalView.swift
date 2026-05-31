//
//  StatisticsDetailModalView.swift
//  TrackIt
//
//  Общий bottom sheet для подробностей карточек статистики.
//

import SwiftUI

struct StatisticsDetailModalView: View {
    let destination: StatisticsDetailDestination
    let snapshot: StatisticsSnapshot
    let periodTitle: String
    let progressSupportText: String
    let streakSupportText: String
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void
    let onChangeDestination: (StatisticsDetailDestination) -> Void
    let onMarkTaskIncomplete: (Task) -> Void

    private var maxContentHeight: CGFloat {
        UIScreen.main.bounds.height * 0.62
    }

    var body: some View {
        VStack(spacing: 0) {
            ModalDragHandle(dragState: dragState, showsDragHandle: false, onDismiss: onDismiss) {
                header
            }
            Divider()
            AdaptiveSheetContent(maxHeight: maxContentHeight) {
                detailContent
                    .padding(20)
                    .id(destination.id)
                    .transition(.opacity)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .contentShape(Rectangle())
        .onTapGesture { }
        .simultaneousGesture(horizontalSwipeGesture)
        .modalDragOffset(dragState)
        .animation(.snappySpring, value: destination.id)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: destination.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(destination.iconColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(.label))
                Text(periodTitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var horizontalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > 72, abs(horizontal) > abs(vertical) * 1.25 else { return }

                if horizontal < 0, let next = destination.next {
                    onChangeDestination(next)
                } else if horizontal > 0, let previous = destination.previous {
                    onChangeDestination(previous)
                }
            }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch destination {
        case .progress:
            StatisticsProgressDetailView(summary: snapshot.progress, supportText: progressSupportText)
        case .completedTasks:
            StatisticsCompletedTasksDetailView(
                tasks: snapshot.completedTasks,
                periodTitle: periodTitle,
                onMarkTaskIncomplete: onMarkTaskIncomplete
            )
        case .streak:
            StatisticsStreakDetailView(summary: snapshot.streak, supportText: streakSupportText)
        case .productivityTrend:
            StatisticsTrendDetailView(days: snapshot.trendDays, bestDay: snapshot.bestProductivityDay)
        }
    }
}
