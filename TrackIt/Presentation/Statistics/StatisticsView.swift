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
    @State private var highlightedFields = Set<ProgressAnalyticsField>()
    @State private var celebrationID: UUID?
    @State private var resetAnimationWorkItem: DispatchWorkItem?
    @StateObject private var progressModalDragState = ModalDragState()
    private let applicationInfo = AppInfoProvider.current()

    private var isNarrowScreen: Bool { UIScreen.main.bounds.width <= 340 }
    private var modalHorizontalPadding: CGFloat { isNarrowScreen ? 16 : 24 }

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        StatisticsCompletionRingView(
                            completionRate: vm.completionRate,
                            supportText: vm.progressSupportText,
                            isNarrowScreen: isNarrowScreen,
                            isHighlighted: highlightedFields.contains(.completionRate),
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
                .background(Color(.secondarySystemBackground))
                .navigationTitle("Ваш прогресс")
                .navigationBarTitleDisplayMode(.large)
            }
            .allowsHitTesting(activeDetail == nil)

            celebrationOverlay
            progressModalOverlay
        }
        .background(TabBarHider(hide: activeDetail != nil))
        .onAppear(perform: refreshAndPlayPendingAnimations)
        .onDisappear(perform: cancelPendingAnimationReset)
        .onChange(of: vm.analyticsDelta?.id) { _, _ in
            playAnalyticsDeltaIfNeeded(vm.analyticsDelta)
        }
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
            isHighlighted: highlightedFields.contains(.completedCount),
            action: { openDetail(.completedTasks) }
        )
    }

    private var streakStatCard: some View {
        ProgressStatCardView(
            icon: "flame.fill",
            iconColor: Color(.systemOrange),
            value: "\(vm.streakDays)",
            label: "Дней подряд",
            isHighlighted: highlightedFields.contains(.streakDays),
            action: { openDetail(.streak) }
        )
    }

    @ViewBuilder
    private var celebrationOverlay: some View {
        if let celebrationID {
            ProgressCelebrationView()
                .id(celebrationID)
                .allowsHitTesting(false)
                .zIndex(8)
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        SettingsSectionView()
    }

    // MARK: - App Info

    private var appInfo: some View {
        VStack(spacing: 4) {
            Text("\(applicationInfo.name) Version \(applicationInfo.version)")
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
                onDismiss: dismissModals,
                onChangeDestination: changeActiveDetail,
                onMarkTaskIncomplete: vm.markTaskIncomplete
            )
            .padding(.horizontal, modalHorizontalPadding)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
            .zIndex(11)
        }
    }

    private func dismissModals() {
        withAnimation(.sheetSpring) {
            activeDetail = nil
        }
    }

    private func openDetail(_ destination: StatisticsDetailDestination) {
        progressModalDragState.reset()
        withAnimation(.sheetSpring) { activeDetail = destination }
    }

    private func changeActiveDetail(_ destination: StatisticsDetailDestination) {
        withAnimation(.snappySpring) { activeDetail = destination }
    }

    private func refreshAndPlayPendingAnimations() {
        vm.refreshAnalytics()
        playAnalyticsDeltaIfNeeded(vm.analyticsDelta)
    }

    private func playAnalyticsDeltaIfNeeded(_ delta: ProgressAnalyticsDelta?) {
        guard let delta, delta.hasPositiveChanges else { return }

        resetAnimationWorkItem?.cancel()
        withAnimation(.snappySpring) {
            highlightedFields = delta.improvedFields
            celebrationID = delta.id
        }

        let resetWorkItem = DispatchWorkItem {
            guard celebrationID == delta.id else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                highlightedFields.removeAll()
                celebrationID = nil
            }
        }
        resetAnimationWorkItem = resetWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.celebrationDuration, execute: resetWorkItem)
        vm.consumeAnalyticsDelta(delta.id)
    }

    private func cancelPendingAnimationReset() {
        resetAnimationWorkItem?.cancel()
        resetAnimationWorkItem = nil
        highlightedFields.removeAll()
        celebrationID = nil
    }

    private enum Constants {
        static let celebrationDuration: TimeInterval = 1.55
    }
}
