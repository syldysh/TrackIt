//
//  StatisticsView.swift
//  TrackIt
//
//  Экран «Ваш прогресс» — кольцо выполнения, статистика, график активности, настройки.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: StatisticsViewModel
    @State private var activeDetail: StatisticsDetailDestination? = nil
    @State private var selectedSettingsDestination: SettingsDestination? = nil
    @StateObject private var progressModalDragState = ModalDragState()
    @StateObject private var settingsModalDragState = ModalDragState()

    private var isNarrowScreen: Bool { UIScreen.main.bounds.width <= 340 }
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
                        StatisticsCompletionRingView(
                            completionRate: vm.completionRate,
                            supportText: vm.progressSupportText,
                            isNarrowScreen: isNarrowScreen,
                            action: { openDetail(.progress) }
                        )
                        statCards
                        StatisticsActivityChartView(
                            days: vm.trendDays,
                            isNarrowScreen: isNarrowScreen,
                            action: { openDetail(.productivityTrend) }
                        )
                        settingsSection
                        appInfo
                    }
                    .padding(16)
                }
            }

            progressModalOverlay
            settingsModalOverlay
        }
        .background(TabBarHider(hide: activeDetail != nil || selectedSettingsDestination != nil))
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
            action: { openDetail(.completedTasks) }
        )
    }

    private var streakStatCard: some View {
        ProgressStatCardView(
            icon: "flame.fill",
            iconColor: Color(.systemOrange),
            value: "\(vm.streakDays)",
            label: "Дней подряд",
            action: { openDetail(.streak) }
        )
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
            Text("Made with love <3")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 8)
    }

    // MARK: - Modals

    @ViewBuilder
    private var progressModalOverlay: some View {
        if activeDetail != nil {
            ModalDimBackground(dragState: progressModalDragState, baseOpacity: 0.3) {
                dismissModals()
            }
                .transition(.opacity)
                .zIndex(10)
        }

        if let activeDetail {
            StatisticsDetailModalView(
                destination: activeDetail,
                snapshot: vm.statistics,
                periodTitle: vm.periodTitle,
                progressSupportText: vm.progressSupportText,
                streakSupportText: vm.streakSupportText,
                dragState: progressModalDragState,
                onDismiss: dismissModals
            )
            .frame(maxHeight: UIScreen.main.bounds.height * 0.76)
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
            activeDetail = nil
            selectedSettingsDestination = nil
        }
    }

    private func openDetail(_ destination: StatisticsDetailDestination) {
        progressModalDragState.reset()
        withAnimation(.sheetSpring) { activeDetail = destination }
    }
}
