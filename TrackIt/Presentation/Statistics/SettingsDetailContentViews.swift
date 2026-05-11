//
//  SettingsDetailContentViews.swift
//  TrackIt
//
//  Тексты и небольшие блоки для экранов настроек.
//  Здесь нет навигации, только содержимое модальных окон.
//

import SwiftUI

struct NotificationSettingsContent: View {
    @AppStorage("settings.taskRemindersEnabled") private var taskRemindersEnabled = true
    @AppStorage("settings.progressRemindersEnabled") private var progressRemindersEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            settingsCard {
                settingsToggleRow(
                    title: "Напоминания о задачах",
                    subtitle: "Подсказывать о задачах с выбранным временем",
                    icon: "clock.fill",
                    isOn: $taskRemindersEnabled
                )
                Divider().padding(.leading, 48)
                settingsToggleRow(
                    title: "Сводка прогресса",
                    subtitle: "Напоминать возвращаться к плану дня",
                    icon: "chart.bar.fill",
                    isOn: $progressRemindersEnabled
                )
            }

            settingsInfoCard(
                icon: "bell.badge.fill",
                title: "Уведомления",
                text: "Разрешение iOS запрашивается, когда вы впервые включаете уведомление у задачи с выбранным временем. Если доступ запрещён, включите его в настройках системы."
            )
        }
    }
}

struct HelpFeedbackContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HelpStepView(
                icon: "plus.circle.fill",
                title: "Создание задачи",
                text: "На вкладке календаря нажмите плюс, введите название, выберите дату, время и длительность."
            )
            HelpStepView(
                icon: "tray.fill",
                title: "Планировщик",
                text: "Добавляйте задачи без даты во входящие, а затем распределяйте их через режим планирования."
            )
            HelpStepView(
                icon: "calendar",
                title: "Календарь",
                text: "Переключайтесь между месяцем, неделей и днем, чтобы смотреть задачи в нужном масштабе."
            )
            HelpStepView(
                icon: "chart.bar.fill",
                title: "Прогресс",
                text: "Экран прогресса показывает выполненные задачи, серию дней и активность за неделю."
            )

            settingsInfoCard(
                icon: "envelope.fill",
                title: "Обратная связь",
                text: "Если что-то работает не так, опишите сценарий, экран и действие, после которого появилась проблема."
            )
        }
    }
}

struct AboutAppContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.brandAccent)
                Text("TrackIt")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(.label))
                Text("Версия 1.0.0")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(18)

            settingsInfoCard(
                icon: "sparkles",
                title: "О приложении",
                text: "TrackIt помогает собирать задачи, планировать день в календаре и видеть прогресс без лишней сложности."
            )
            settingsInfoCard(
                icon: "person.fill",
                title: "Автор",
                text: "Проект создан Сылдыс Шогжал как iOS-приложение для задач, календаря, планирования и прогресса."
            )
            settingsInfoCard(
                icon: "hammer.fill",
                title: "Технологии",
                text: "SwiftUI, MVVM и локальное хранение задач через CoreData."
            )
        }
    }
}

private struct HelpStepView: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        settingsInfoCard(icon: icon, title: title, text: text)
    }
}

@ViewBuilder
private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 0) {
        content()
    }
    .background(Color(.secondarySystemBackground))
    .cornerRadius(18)
}

private func settingsToggleRow(
    title: String,
    subtitle: String,
    icon: String,
    isOn: Binding<Bool>
) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .background(Color.brandAccent)
            .cornerRadius(9)

        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
        .layoutPriority(1)
        Spacer(minLength: 8)
        Toggle("", isOn: isOn)
            .labelsHidden()
    }
    .padding(14)
}

private func settingsInfoCard(icon: String, title: String, text: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .background(Color.brandAccent)
            .cornerRadius(9)

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(18)
}
