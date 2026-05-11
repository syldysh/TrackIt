//
//  StatisticsSettingsRow.swift
//  TrackIt
//
//  Переиспользуемая строка настроек в стиле iOS Settings.
//

import SwiftUI

struct StatisticsSettingsRow: View {
    let destination: SettingsDestination

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: destination.icon)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.brandAccent)
                .cornerRadius(8)

            Text(destination.title)
                .font(.system(size: 16))
                .foregroundColor(Color(.label))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .contentShape(Rectangle())
        .background(Color(.systemBackground))
    }
}
