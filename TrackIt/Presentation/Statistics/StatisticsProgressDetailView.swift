//
//  StatisticsProgressDetailView.swift
//  TrackIt
//
//  Подробности общей карточки прогресса.
//

import SwiftUI

struct StatisticsProgressDetailView: View {
    let summary: StatisticsProgressSummary
    let supportText: String

    var body: some View {
        VStack(spacing: 16) {
            if summary.totalCount == 0 {
                emptyState
            } else {
                progressHero
                metricRow(title: "Выполнено", value: "\(summary.completedCount)")
                metricRow(title: "Всего задач", value: "\(summary.totalCount)")
                metricRow(title: "Процент выполнения", value: "\(summary.completionRate)%")
                Text(supportText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var progressHero: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)
                .frame(width: 128, height: 128)
            Circle()
                .trim(from: 0, to: CGFloat(summary.completionRate) / 100)
                .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 128, height: 128)
                .rotationEffect(.degrees(-90))
            Text("\(summary.completionRate)%")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.brandAccent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 28))
                .foregroundColor(.brandAccent)
                .frame(width: 64, height: 64)
                .background(Color.brandAccent.opacity(0.12))
                .clipShape(Circle())
            Text("Пока нет задач за период")
                .font(.system(size: 18, weight: .semibold))
            Text("Запланируйте задачу, и прогресс появится здесь.")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 18)
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.label))
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}
