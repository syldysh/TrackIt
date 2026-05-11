//
//  StatisticsSettingsComponents.swift
//  TrackIt
//
//  Общие UI-компоненты для экранов настроек статистики.
//

import SwiftUI

struct StatisticsSettingsGroup<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .sectionHeaderStyle()
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(18)
        }
    }
}

struct StatisticsSettingsIntroCard<Icon: View>: View {
    let title: String
    let subtitle: String
    private let icon: Icon

    init(title: String, subtitle: String, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            icon

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
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

struct StatisticsSettingsIcon: View {
    let systemName: String
    var size: CGFloat = 62
    var fontSize: CGFloat = 28

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: fontSize))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(Color.brandAccent)
            .cornerRadius(size * 0.26)
    }
}
