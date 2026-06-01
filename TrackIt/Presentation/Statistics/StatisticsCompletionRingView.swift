//
//  StatisticsCompletionRingView.swift
//  TrackIt
//
//  Карточка кольца выполнения на экране прогресса.
//

import SwiftUI

struct StatisticsCompletionRingView: View {
    let completionRate: Int
    let displayedCompletionRate: Double
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
                .trim(from: 0, to: progress)
                .stroke(
                    Color.brandAccent.opacity(isHighlighted ? Constants.glowOpacity : 0),
                    style: StrokeStyle(lineWidth: ringLineWidth + Constants.glowLineWidth, lineCap: .round)
                )
                .blur(radius: Constants.glowBlur)
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: Color.brandAccent.opacity(isHighlighted ? Constants.shadowOpacity : 0),
                    radius: Constants.shadowRadius,
                    y: Constants.shadowYOffset
                )
            VStack(spacing: 4) {
                AnimatedPercentText(value: displayedCompletionRate, isHighlighted: isHighlighted)
                Text("Выполнено")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .scaleEffect(isHighlighted ? Constants.highlightScale : 1)
        .animation(Constants.highlightAnimation, value: isHighlighted)
    }

    private var progress: CGFloat {
        CGFloat((displayedCompletionRate / 100).clamped(to: 0...1))
    }

    fileprivate enum Constants {
        static let glowOpacity = 0.26
        static let glowLineWidth: CGFloat = 8
        static let glowBlur: CGFloat = 5
        static let shadowOpacity = 0.32
        static let shadowRadius: CGFloat = 12
        static let shadowYOffset: CGFloat = 1
        static let highlightScale: CGFloat = 1.035
        static let percentHighlightScale: CGFloat = 1.08
        static let percentTextWidth: CGFloat = 130
        static let highlightAnimation = Animation.interactiveSpring(response: 0.36, dampingFraction: 0.72)
    }

}

private struct AnimatedPercentText: View, Animatable {
    var value: Double
    let isHighlighted: Bool

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value.rounded()))%")
            .font(.system(size: 44, weight: .bold))
            .foregroundColor(.brandAccent)
            .contentTransition(.numericText())
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .frame(width: StatisticsCompletionRingView.Constants.percentTextWidth)
            .scaleEffect(isHighlighted ? StatisticsCompletionRingView.Constants.percentHighlightScale : 1)
            .animation(StatisticsCompletionRingView.Constants.highlightAnimation, value: isHighlighted)
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
