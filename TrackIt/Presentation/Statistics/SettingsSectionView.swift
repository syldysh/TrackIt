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
            settingsGroup(title: "Настройки") {
                settingsRow(.notifications)
            }
            settingsGroup(title: "Поддержка") {
                settingsRow(.help)
                Divider().padding(.leading, 52)
                settingsRow(.privacy)
                Divider().padding(.leading, 52)
                settingsRow(.about)
            }
        }
    }

    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .sectionHeaderStyle()
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
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
        case .notifications:
            StatisticsNotificationSettingsView()
        case .help, .privacy, .about:
            StatisticsSettingsPlaceholderView(destination: destination)
        }
    }
}
