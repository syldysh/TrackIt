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
                    .foregroundColor(Color(.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
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
        }
        .buttonStyle(ProgressStatCardButtonStyle())
        .accessibilityLabel("\(value), \(label)")
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
