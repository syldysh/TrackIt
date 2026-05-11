//
//  StatisticsAboutAppView.swift
//  TrackIt
//
//  Экран информации о приложении в настройках статистики.
//

import SwiftUI
import UIKit

struct StatisticsAboutAppView: View {
    private let appInfo = AppInfoProvider.current()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                introCard
                descriptionSection
                infoSection
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introCard: some View {
        StatisticsSettingsIntroCard(
            title: appInfo.name,
            subtitle: "Задачи, календарь, планирование и прогресс в одном приложении."
        ) {
            AppIconView()
        }
    }

    private var descriptionSection: some View {
        StatisticsSettingsGroup(title: "Описание") {
            VStack(alignment: .leading, spacing: 10) {
                Text("TrackIt помогает собирать задачи, планировать их в календаре и следить за прогрессом без лишней сложности.")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var infoSection: some View {
        StatisticsSettingsGroup(title: "Информация") {
            AboutInfoRow(icon: "tag.fill", title: "Версия", value: appInfo.version)
            Divider().padding(.leading, AboutLayout.dividerLeading)
            AboutInfoRow(icon: "person.fill", title: "Автор", value: appInfo.author)
        }
    }
}

private struct AppIconView: View {
    var body: some View {
        if let image = UIImage(named: "AppIcon") ?? UIImage(named: "LaunchLogo") {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        } else {
            StatisticsSettingsIcon(systemName: "checkmark.square", size: 92, fontSize: 42)
        }
    }
}

private struct AboutInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            StatisticsSettingsIcon(systemName: icon, size: AboutLayout.iconSize, fontSize: 15)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(.label))

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 16))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum AboutLayout {
    static let iconSize: CGFloat = 34
    static var dividerLeading: CGFloat { 14 + iconSize + 12 }
}
