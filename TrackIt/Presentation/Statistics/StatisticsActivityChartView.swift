//
//  StatisticsActivityChartView.swift
//  TrackIt
//
//  Карточка недельного графика активности.
//

import SwiftUI

struct StatisticsActivityChartView: View {
    let activity: [Int]
    let isNarrowScreen: Bool

    private var chartHeight: CGFloat { isNarrowScreen ? 140 : 160 }
    private var barMaxHeight: CGFloat { isNarrowScreen ? 118 : 140 }
    private var maxValue: Int { max(activity.max() ?? 1, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            bars
            Text("Задач выполнено за последние 7 дней")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(24)
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

    private var bars: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(activity.enumerated()), id: \.offset) { index, value in
                VStack(spacing: 4) {
                    let height = CGFloat(value) / CGFloat(maxValue) * barMaxHeight
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.brandAccent)
                        .frame(height: max(height, 6))
                        .animation(.easeOut, value: value)
                    Text(RuDate.shortWeekday(at: index))
                        .font(.system(size: 11))
                        .foregroundColor(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: chartHeight)
    }
}
