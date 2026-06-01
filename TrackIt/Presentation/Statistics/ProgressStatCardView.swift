//
//  ProgressStatCardView.swift
//  TrackIt
//
//  Нажимаемая карточка статистики на экране прогресса.
//  Используется для выполненных задач и стрика.
//

import SwiftUI

struct ProgressStatCardView: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Circle()
                    .fill(iconColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    )
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isHighlighted ? iconColor : Color(.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .contentTransition(.numericText())
                    .scaleEffect(isHighlighted ? Constants.valueHighlightScale : 1)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(iconColor.opacity(isHighlighted ? 0.42 : 0), lineWidth: 2)
            )
            .shadow(color: iconColor.opacity(isHighlighted ? Constants.highlightShadowOpacity : 0), radius: 10, y: 4)
            .scaleEffect(isHighlighted ? Constants.cardHighlightScale : 1)
            .animation(Constants.highlightAnimation, value: isHighlighted)
            .animation(Constants.valueAnimation, value: value)
        }
        .buttonStyle(ProgressStatCardButtonStyle())
        .accessibilityLabel("\(value), \(label)")
    }

    private enum Constants {
        static let cardHighlightScale: CGFloat = 1.03
        static let valueHighlightScale: CGFloat = 1.08
        static let highlightShadowOpacity = 0.18
        static let highlightAnimation = Animation.interactiveSpring(response: 0.34, dampingFraction: 0.72)
        static let valueAnimation = Animation.easeOut(duration: 0.28)
    }
}

private struct ProgressStatCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.snappySpring, value: configuration.isPressed)
    }
}
