//
//  StatisticsCompletionRingView.swift
//  TrackIt
//
//  Карточка кольца выполнения на экране прогресса.
//

import SwiftUI

struct StatisticsCompletionRingView: View {
    let completionRate: Int
    let supportText: String
    let isNarrowScreen: Bool
    let isHighlighted: Bool
    let action: () -> Void

    private var ringSize: CGFloat { isNarrowScreen ? 156 : 180 }
    private var ringLineWidth: CGFloat { isNarrowScreen ? 12 : 14 }

    var body: some View {
        Button(action: action) {
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
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.brandAccent.opacity(isHighlighted ? 0.38 : 0), lineWidth: 2)
            )
            .scaleEffect(isHighlighted ? 1.015 : 1)
            .animation(.snappySpring, value: isHighlighted)
        }
        .buttonStyle(StatisticsCardButtonStyle())
        .accessibilityLabel("Прогресс \(completionRate) процентов")
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
                    .scaleEffect(isHighlighted ? 1.06 : 1)
                    .animation(.snappySpring, value: isHighlighted)
                Text("Выполнено")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }

}

struct StatisticsCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.snappySpring, value: configuration.isPressed)
    }
}
