//
//  StreakModalView.swift
//  TrackIt
//
//  Подробности карточки серии дней.
//

import SwiftUI

struct StatisticsStreakDetailView: View {
    let summary: StatisticsStreakSummary
    let supportText: String

    var body: some View {
        VStack(spacing: 18) {
            hero
            Text(supportText)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            explanation
            recentActivity
        }
        .frame(maxWidth: .infinity)
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 34))
                .foregroundColor(.brandOrange)
                .frame(width: 76, height: 76)
                .background(Color.brandOrange.opacity(0.14))
                .clipShape(Circle())
            Text("\(summary.days)")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(Color(.label))
            Text(dayWord)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private var explanation: some View {
        Text("День засчитывается в серию после выполнения хотя бы одной запланированной задачи.")
            .font(.system(size: 14))
            .foregroundColor(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Последние 7 дней")
                .font(.system(size: 15, weight: .semibold))
            ForEach(summary.recentDays.reversed()) { day in
                HStack {
                    Text(RuDate.shortDayLabel(day.date))
                        .font(.system(size: 14))
                        .foregroundColor(Color(.label))
                    Spacer()
                    Text(day.completedCount > 0 ? "\(day.completedCount) выполнено" : "Нет выполненных")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(day.completedCount > 0 ? .brandGreen : Color(.secondaryLabel))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dayWord: String {
        let mod10 = summary.days % 10
        let mod100 = summary.days % 100
        if mod10 == 1 && mod100 != 11 { return "день подряд" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "дня подряд" }
        return "дней подряд"
    }
}
