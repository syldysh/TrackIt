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

    var body: some View {
        VStack(spacing: 0) {
            ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
                header
            }
            Divider()
            ScrollView {
                detailContent
                    .padding(20)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .modalDragOffset(dragState)
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

    @ViewBuilder
    private var detailContent: some View {
        switch destination {
        case .progress:
            StatisticsProgressDetailView(summary: snapshot.progress, supportText: progressSupportText)
        case .completedTasks:
            StatisticsCompletedTasksDetailView(tasks: snapshot.completedTasks, periodTitle: periodTitle)
        case .streak:
            StatisticsStreakDetailView(summary: snapshot.streak, supportText: streakSupportText)
        case .productivityTrend:
            StatisticsTrendDetailView(days: snapshot.trendDays, bestDay: snapshot.bestProductivityDay)
        }
    }
}
