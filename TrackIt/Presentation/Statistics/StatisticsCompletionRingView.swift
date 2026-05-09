//
//  StatisticsCompletionRingView.swift
//  TrackIt
//
//  Карточка кольца выполнения на экране прогресса.
//

import SwiftUI

struct StatisticsCompletionRingView: View {
    let completionRate: Int
    let isNarrowScreen: Bool

    private var ringSize: CGFloat { isNarrowScreen ? 156 : 180 }
    private var ringLineWidth: CGFloat { isNarrowScreen ? 12 : 14 }

    var body: some View {
        VStack(spacing: 12) {
            ring
            Text(supportText)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(isNarrowScreen ? 20 : 28)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: ringLineWidth)
                .frame(width: ringSize, height: ringSize)
            Circle()
                .trim(from: 0, to: CGFloat(completionRate) / 100)
                .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1), value: completionRate)
            VStack(spacing: 4) {
                Text("\(completionRate)%")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.brandAccent)
                Text("Выполнено")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }

    private var supportText: String {
        completionRate >= 70
        ? "Отличная работа! Вы опережаете свою недельную цель"
        : "Продолжайте — вы на верном пути!"
    }
}
