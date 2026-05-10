//
//  StatisticsActivityChartView.swift
//  TrackIt
//
//  Карточка недельного графика активности.
//

import SwiftUI

struct StatisticsActivityChartView: View {
    let days: [StatisticsDailySummary]
    let isNarrowScreen: Bool
    let action: () -> Void

    private var barMaxHeight: CGFloat { isNarrowScreen ? 92 : 112 }
    private var maxValue: Int { max(days.map(\.completedCount).max() ?? 1, 1) }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                header
                chart
                Text("Задач выполнено за последние 7 дней")
                    .font(.system(size: 13))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(24)
        }
        .buttonStyle(StatisticsCardButtonStyle())
        .accessibilityLabel("Тренд продуктивности")
    }

    private var header: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(.systemPurple))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )
            Text("Тренд продуктивности")
                .font(.system(size: 18, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
    }

    private var chart: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(barColor(for: day))
                        .frame(height: barHeight(for: day))
                        .frame(maxWidth: .infinity)
                        .animation(.easeOut(duration: 0.25), value: day.completedCount)
                }
            }
            .frame(height: barMaxHeight, alignment: .bottom)

            HStack(spacing: 8) {
                ForEach(days) { day in
                    Text(RuDate.shortWeekday(at: RuDate.isoWeekday(day.date)))
                        .font(.system(size: 11))
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 16)
        }
    }

    private func barHeight(for day: StatisticsDailySummary) -> CGFloat {
        guard day.completedCount > 0 else { return 6 }
        return max(CGFloat(day.completedCount) / CGFloat(maxValue) * barMaxHeight, 10)
    }

    private func barColor(for day: StatisticsDailySummary) -> Color {
        day.completedCount > 0 ? .brandAccent : Color(.systemGray5)
    }
}
