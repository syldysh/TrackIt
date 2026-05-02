//
//  CalendarDayLabelView.swift
//  TrackIt
//
//  Подпись выбранного дня в дневном режиме календаря.
//  Показывает дату и небольшой бейдж, если это сегодня.
//

import SwiftUI

struct CalendarDayLabelView: View {
    let selectedDate: Date
    let todayString: String

    var body: some View {
        HStack(spacing: 8) {
            Text(RuDate.dateDayLabel(selectedDate))
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
            if RuDate.isoString(from: selectedDate) == todayString {
                Text("сегодня")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandAccent)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}
