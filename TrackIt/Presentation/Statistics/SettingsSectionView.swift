//
//  SettingsSectionView.swift
//  TrackIt
//
//  Секция настроек на экране прогресса.
//  Собирает пункты меню и открывает отдельные экраны через навигацию.
//

import SwiftUI

struct SettingsSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StatisticsSettingsGroup(title: "Поддержка") {
                settingsRow(.help)
                Divider().padding(.leading, 52)
                settingsRow(.about)
            }
        }
    }

    private func settingsRow(_ destination: SettingsDestination) -> some View {
        NavigationLink {
            destinationView(for: destination)
        } label: {
            StatisticsSettingsRow(destination: destination)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destinationView(for destination: SettingsDestination) -> some View {
        switch destination {
        case .help:
            StatisticsHelpFeedbackView()
        case .about:
            StatisticsAboutAppView()
        }
    }
}
