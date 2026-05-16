//
//  StatisticsTrendDetailView.swift
//  TrackIt
//
//  Подробности тренда продуктивности за текущую неделю.
//

import SwiftUI

struct StatisticsTrendDetailView: View {
    let days: [StatisticsDailySummary]
    let bestDay: StatisticsDailySummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            bestDaySummary
            dayRows
        }
    }

    @ViewBuilder
    private var bestDaySummary: some View {
        if let bestDay {
            VStack(alignment: .leading, spacing: 6) {
                Text("Лучший день")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
                Text("\(RuDate.shortDayLabel(bestDay.date)) — \(bestDay.completionRate)%")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(.label))
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text("\(bestDay.completedCount) из \(bestDay.totalCount) \(RuDate.pluralTasks(bestDay.totalCount)) выполнено.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.brandPurple.opacity(0.1))
            .cornerRadius(16)
        } else {
            emptyBestDay
        }
    }

    private var emptyBestDay: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar")
                .font(.system(size: 26))
                .foregroundColor(Color(.systemGray3))
            Text("Пока нет данных для тренда")
                .font(.system(size: 17, weight: .semibold))
            Text("Запланируйте и выполните задачи, чтобы увидеть продуктивные дни.")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var dayRows: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Разбивка по дням")
                .font(.system(size: 15, weight: .semibold))

            ForEach(days.reversed()) { day in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(RuDate.shortDayLabel(day.date))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(.label))
                        Text("\(day.completedCount) из \(day.totalCount) выполнено")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    Spacer()
                    Text("\(day.completionRate)%")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(day.totalCount > 0 ? .brandAccent : Color(.secondaryLabel))
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
}
