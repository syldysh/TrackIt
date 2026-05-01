//
//  StatisticsView.swift
//  TrackIt
//
//  Экран «Ваш прогресс» — кольцо выполнения, статистика, график активности, настройки.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: StatisticsViewModel
    @State private var showCompletedTasks = false
    @State private var showStreakDetails = false
    @State private var selectedSettingsDestination: SettingsDestination? = nil
    @StateObject private var progressModalDragState = ModalDragState()
    @StateObject private var settingsModalDragState = ModalDragState()

    private var isNarrowScreen: Bool { UIScreen.main.bounds.width <= 340 }
    private var ringSize: CGFloat { isNarrowScreen ? 156 : 180 }
    private var ringLineWidth: CGFloat { isNarrowScreen ? 12 : 14 }
    private var chartHeight: CGFloat { isNarrowScreen ? 140 : 160 }
    private var barMaxHeight: CGFloat { isNarrowScreen ? 118 : 140 }
    private var modalHorizontalPadding: CGFloat { isNarrowScreen ? 16 : 24 }

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Ваш прогресс")
                        .font(.system(size: 34, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
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

            progressModalOverlay
            settingsModalOverlay
        }
        .background(TabBarHider(hide: showCompletedTasks || showStreakDetails || selectedSettingsDestination != nil))
    }

    // MARK: - Completion Ring

    private var completionRing: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: ringLineWidth)
                    .frame(width: ringSize, height: ringSize)
                Circle()
                    .trim(from: 0, to: CGFloat(vm.completionRate) / 100)
                    .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(isNarrowScreen ? 20 : 28)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }

    // MARK: - Stat Cards

    private var statCards: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                completedStatCard
                streakStatCard
            }
            VStack(spacing: 12) {
                completedStatCard
                streakStatCard
            }
        }
    }

    private var completedStatCard: some View {
        ProgressStatCardView(
            icon: "checkmark.circle.fill",
            iconColor: Color(.systemGreen),
            value: "\(vm.completedCount)",
            label: "Задач выполнено",
            action: {
                progressModalDragState.reset()
                withAnimation(.sheetSpring) { showCompletedTasks = true }
            }
        )
    }

    private var streakStatCard: some View {
        ProgressStatCardView(
            icon: "flame.fill",
            iconColor: Color(.systemOrange),
            value: "\(vm.streakDays)",
            label: "Дней подряд",
            action: {
                progressModalDragState.reset()
                withAnimation(.sheetSpring) { showStreakDetails = true }
            }
        )
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(activity.enumerated()), id: \.offset) { i, value in
                    VStack(spacing: 4) {
                        let h = CGFloat(value) / CGFloat(maxVal) * barMaxHeight
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
            .frame(height: chartHeight)

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
        SettingsSectionView { destination in
            settingsModalDragState.reset()
            withAnimation(.sheetSpring) {
                selectedSettingsDestination = destination
            }
        }
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

    // MARK: - Modals

    @ViewBuilder
    private var progressModalOverlay: some View {
        if showCompletedTasks || showStreakDetails {
            ModalDimBackground(dragState: progressModalDragState, baseOpacity: 0.3) {
                dismissModals()
            }
                .transition(.opacity)
                .zIndex(10)
        }

        if showCompletedTasks {
            CompletedTasksModalView(tasks: vm.completedTasks, dragState: progressModalDragState) {
                dismissModals()
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.74)
            .padding(.horizontal, modalHorizontalPadding)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
            .zIndex(11)
        }

        if showStreakDetails {
            StreakModalView(
                streakDays: vm.streakDays,
                supportText: vm.streakSupportText,
                dragState: progressModalDragState,
                onDismiss: dismissModals
            )
            .frame(maxHeight: UIScreen.main.bounds.height * 0.72)
            .padding(.horizontal, modalHorizontalPadding)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
            .zIndex(11)
        }
    }

    @ViewBuilder
    private var settingsModalOverlay: some View {
        if let destination = selectedSettingsDestination {
            ModalDimBackground(dragState: settingsModalDragState, baseOpacity: 0.3) {
                dismissModals()
            }
                .transition(.opacity)
                .zIndex(20)

            SettingsDetailModalView(destination: destination, dragState: settingsModalDragState) {
                dismissModals()
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
            .padding(.horizontal, modalHorizontalPadding)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
            .zIndex(21)
        }
    }

    private func dismissModals() {
        withAnimation(.sheetSpring) {
            showCompletedTasks = false
            showStreakDetails = false
            selectedSettingsDestination = nil
        }
    }
}
