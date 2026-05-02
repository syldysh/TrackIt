//
//  SettingsSectionView.swift
//  TrackIt
//
//  Секция настроек на экране прогресса.
//  Собирает пункты меню и передает выбранный пункт наружу.
//

import SwiftUI

struct SettingsSectionView: View {
    let onSelect: (SettingsDestination) -> Void

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
        Button {
            onSelect(destination)
        } label: {
            HStack(spacing: 12) {
                settingIcon(destination.icon)
                Text(destination.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
    }

    private func settingIcon(_ name: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brandAccent)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: name)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            )
    }
}

private struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray6) : Color.clear)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.snappySpring, value: configuration.isPressed)
    }
}
