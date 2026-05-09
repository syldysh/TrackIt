//
//  CalendarEmptyDayPlaceholder.swift
//  TrackIt
//
//  Пустое состояние для дня без задач.
//  Помогает экрану не выглядеть сломанным, когда в выбранный день ничего нет.
//

import SwiftUI

struct CalendarEmptyDayPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.systemGray3))
                )
            Text("Нет задач на этот день")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
            Text("Выберите день в календаре")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
        .frame(maxWidth: .infinity)
    }
}
