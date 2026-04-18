//
//  StatisticsView.swift
//  TrackIt
//
//  Экран «Ваш прогресс» — кольцо выполнения, статистика, график активности, настройки.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: StatisticsViewModel

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Ваш прогресс")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))

                ScrollView {
                    VStack(spacing: 16) {
                        completionRing
                        statCards
                        activityChart
                        settingsSection
                        appInfo
                    }
                    .padding(16)
                }
            }
        }
    }

    // MARK: - Completion Ring

    private var completionRing: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 14)
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: CGFloat(vm.completionRate) / 100)
                    .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1), value: vm.completionRate)
                VStack(spacing: 4) {
                    Text("\(vm.completionRate)%")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.brandAccent)
                    Text("Выполнено")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            Text(vm.completionRate >= 70
                 ? "Отличная работа! Вы опережаете свою недельную цель"
                 : "Продолжайте — вы на верном пути!")
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.label))
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }

    // MARK: - Stat Cards

    private var statCards: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "checkmark.circle.fill",
                iconColor: Color(.systemGreen),
                value: "\(vm.completedCount)",
                label: "Задач выполнено"
            )
            statCard(
                icon: "flame.fill",
                iconColor: Color(.systemOrange),
                value: "\(vm.streakDays)",
                label: "Дней подряд"
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(iconColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                )
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(.label))
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }

    // MARK: - Activity Chart

    private var activityChart: some View {
        let activity = vm.weeklyActivity()
        let maxVal = max(activity.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(.systemPurple))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                Text("Тренд продуктивности")
                    .font(.system(size: 18, weight: .semibold))
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(activity.enumerated()), id: \.offset) { i, value in
                    VStack(spacing: 4) {
                        let h = CGFloat(value) / CGFloat(maxVal) * 140
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.brandAccent)
                            .frame(height: max(h, 6))
                            .animation(.easeOut, value: value)
                        Text(RuDate.shortWeekday(at: i))
                            .font(.system(size: 11))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)

            Text("Задач выполнено за последние 7 дней")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            settingsGroup(title: "Настройки") {
                settingNavRow(icon: "bell.fill", label: "Уведомления")
            }
            settingsGroup(title: "Поддержка") {
                settingNavRow(icon: "questionmark.circle.fill", label: "Помощь и обратная связь")
                Divider().padding(.leading, 52)
                settingNavRow(icon: "lock.shield.fill", label: "Политика конфиденциальности")
                Divider().padding(.leading, 52)
                settingNavRow(icon: "info.circle.fill", label: "О приложении")
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

    private func settingNavRow(icon: String, label: String) -> some View {
        HStack(spacing: 12) {
            settingIcon(icon)
            Text(label).font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .contentShape(Rectangle())
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

    // MARK: - App Info

    private var appInfo: some View {
        VStack(spacing: 4) {
            Text("TrackIt Version 1.0.0")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
            Text("Made with love")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 8)
    }
}
