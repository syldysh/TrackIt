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
        StatisticsSettingsIntroCard(
            title: "Уведомления",
            subtitle: "Уведомления помогут не забывать о задачах и отслеживать прогресс."
        ) {
            StatisticsSettingsIcon(systemName: "bell.fill")
        }
    }

    private var notificationTypesSection: some View {
        StatisticsSettingsGroup(title: "Типы уведомлений") {
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
            StatisticsSettingsIcon(systemName: icon, size: 34, fontSize: 15)

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
