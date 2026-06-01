//
//  StatisticsView.swift
//  TrackIt
//
//  Экран «Ваш прогресс» — кольцо выполнения, статистика, график активности, настройки.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject var vm: StatisticsViewModel
    @State private var activeDetail: StatisticsDetailDestination? = nil
    @State private var highlightedFields = Set<ProgressAnalyticsField>()
    @State private var celebrationID: UUID?
    @State private var resetAnimationTask: _Concurrency.Task<Void, Never>?
    @State private var hasShownInitialStatistics = false
    @State private var isVisible = false
    @State private var displayedCompletionRate: Double = 0
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
                            displayedCompletionRate: displayedCompletionRate,
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
                        SettingsSectionView()
                        StatisticsAppInfoView(applicationInfo: applicationInfo)
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
        .onAppear(perform: handleAppear)
        .onDisappear(perform: handleDisappear)
        .onChange(of: vm.completionRate) { _, newValue in
            animateCompletionRate(to: newValue, emphasized: false)
        }
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

    private func handleAppear() {
        isVisible = true
        vm.refreshAnalytics()

        if hasShownInitialStatistics {
            animateCompletionRate(to: vm.completionRate, emphasized: false)
            playAnalyticsDeltaIfNeeded(vm.analyticsDelta)
        } else {
            displayedCompletionRate = 0
            hasShownInitialStatistics = true
            if let delta = vm.analyticsDelta {
                vm.consumeAnalyticsDelta(delta.id)
            }
            animateCompletionRate(to: vm.completionRate, emphasized: false)
        }
    }

    private func handleDisappear() {
        isVisible = false
        cancelPendingAnimationReset()
    }

    private func animateCompletionRate(to completionRate: Int, emphasized: Bool) {
        guard isVisible, hasShownInitialStatistics else { return }

        if reduceMotion {
            displayedCompletionRate = Double(completionRate)
        } else {
            withAnimation(emphasized ? StatisticsAnimationTiming.positiveRingAnimation : StatisticsAnimationTiming.entryRingAnimation) {
                displayedCompletionRate = Double(completionRate)
            }
        }
    }

    private func playAnalyticsDeltaIfNeeded(_ delta: ProgressAnalyticsDelta?) {
        guard isVisible, hasShownInitialStatistics, let delta, delta.hasPositiveChanges else { return }

        resetAnimationTask?.cancel()
        animateCompletionRate(to: vm.completionRate, emphasized: delta.didImproveCompletionRate)
        let shouldShowCelebration = !reduceMotion
        let shouldDelayCelebration = delta.didImproveCompletionRate && shouldShowCelebration

        withAnimation(reduceMotion ? StatisticsAnimationTiming.reducedHighlightAnimation : StatisticsAnimationTiming.highlightAnimation) {
            highlightedFields = delta.improvedFields
            celebrationID = shouldShowCelebration && !shouldDelayCelebration ? delta.id : nil
        }

        let resetTask = _Concurrency.Task {
            if shouldDelayCelebration {
                try? await _Concurrency.Task.sleep(nanoseconds: StatisticsAnimationTiming.completionCelebrationDelayNanoseconds)
                guard !_Concurrency.Task.isCancelled else { return }
                await MainActor.run {
                    guard isVisible, highlightedFields == delta.improvedFields else { return }
                    celebrationID = delta.id
                }
            }
            try? await _Concurrency.Task.sleep(nanoseconds: StatisticsAnimationTiming.highlightDurationNanoseconds)
            guard !_Concurrency.Task.isCancelled else { return }
            await MainActor.run {
                guard highlightedFields == delta.improvedFields else { return }
                withAnimation(StatisticsAnimationTiming.reducedHighlightAnimation) {
                    highlightedFields.removeAll()
                    if celebrationID == delta.id {
                        celebrationID = nil
                    }
                }
            }
        }
        resetAnimationTask = resetTask
        vm.consumeAnalyticsDelta(delta.id)
    }

    private func cancelPendingAnimationReset() {
        resetAnimationTask?.cancel()
        resetAnimationTask = nil
        highlightedFields.removeAll()
        celebrationID = nil
    }
}
