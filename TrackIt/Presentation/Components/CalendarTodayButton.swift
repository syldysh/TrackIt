//
//  CalendarTodayButton.swift
//  TrackIt
//
//  Компактная кнопка возврата к сегодняшней дате для календарных пикеров.
//

import SwiftUI

struct CalendarTodayButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.smoothSpring) { action() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12, weight: .semibold))
                Text("Сегодня")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .frame(maxWidth: 88)
            .foregroundColor(.white)
            .background(Color.brandAccent)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
