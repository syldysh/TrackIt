//
//  StatisticsNotificationSettingsView.swift
//  TrackIt
//
//  Экран настроек уведомлений раздела статистики.
//

import SwiftUI

struct StatisticsNotificationSettingsView: View {
    @StateObject private var viewModel = StatisticsNotificationSettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                introCard
                notificationTypesSection
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Уведомления")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $viewModel.permissionAlert, content: permissionAlert)
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            settingsIcon("bell.fill", size: 62, fontSize: 28)

            VStack(alignment: .leading, spacing: 8) {
                Text("Уведомления")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(.label))
                Text("Уведомления помогут не забывать о задачах и отслеживать прогресс.")
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

    private var notificationTypesSection: some View {
        settingsGroup(title: "Типы уведомлений") {
            NotificationSettingToggleRow(
                icon: "checklist",
                title: "Напоминания о задачах",
                subtitle: "Разрешает использовать напоминания для задач с выбранным временем.",
                isOn: Binding(
                    get: { viewModel.taskRemindersEnabled },
                    set: viewModel.setTaskRemindersEnabled
                )
            )
            Divider().padding(.leading, 60)
            NotificationSettingToggleRow(
                icon: "flame.fill",
                title: "Напоминание о страйке",
                subtitle: "Напомним выполнить задачу, чтобы не потерять серию дней.",
                isOn: Binding(
                    get: { viewModel.streakReminderEnabled },
                    set: viewModel.setStreakReminderEnabled
                )
            )
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
            .cornerRadius(18)
        }
    }

    private func settingsIcon(_ name: String, size: CGFloat, fontSize: CGFloat) -> some View {
        Image(systemName: name)
            .font(.system(size: fontSize))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(Color.brandAccent)
            .cornerRadius(size * 0.26)
    }

    private func permissionAlert(_ alert: NotificationPermissionAlert) -> Alert {
        if alert.canOpenSettings {
            return Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                primaryButton: .default(Text("Настройки")) {
                    viewModel.openAppSettings()
                },
                secondaryButton: .cancel(Text("ОК"))
            )
        }

        return Alert(
            title: Text(alert.title),
            message: Text(alert.message),
            dismissButton: .default(Text("ОК"))
        )
    }
}

private struct NotificationSettingToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: Binding<Bool>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            rowIcon(icon)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.label))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            toggleControl
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var toggleControl: some View {
        Toggle("", isOn: isOn)
            .labelsHidden()
            .frame(width: 54, alignment: .trailing)
    }
}

private func rowIcon(_ name: String) -> some View {
    Image(systemName: name)
        .font(.system(size: 15))
        .foregroundColor(.white)
        .frame(width: 34, height: 34)
        .background(Color.brandAccent)
        .cornerRadius(9)
}
