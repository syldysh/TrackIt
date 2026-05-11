//
//  StatisticsSettingsPlaceholderView.swift
//  TrackIt
//
//  Базовый экран раздела настроек статистики.
//

import SwiftUI

struct StatisticsSettingsPlaceholderView: View {
    let destination: SettingsDestination

    var body: some View {
        ScrollView {
            settingsIntroCard
                .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsIntroCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: destination.icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 62, height: 62)
                .background(Color.brandAccent)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {
                Text(destination.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)

                Text(destination.placeholderText)
                    .font(.system(size: 18))
                    .foregroundColor(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }
}
