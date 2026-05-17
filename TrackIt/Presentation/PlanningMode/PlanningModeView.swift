//
//  PlanningModeView.swift
//  TrackIt
//
//  Режим быстрого планирования: карточки задач пролистываются свайпами.
//  Вправо — запланировать, влево — пропустить, вниз — удалить.
//

import SwiftUI

struct PlanningModeView: View {
    @EnvironmentObject var vm: InboxViewModel
    @Binding var isPresented: Bool
    @StateObject private var state: PlanningModeState

    @State private var showScheduler = false
    @State private var pendingTask: Task? = nil
    @StateObject private var scheduleDragState = ModalDragState(dismissDistance: 100, predictedDismissDistance: 190)

    private var cardExitDistance: CGFloat { UIScreen.main.bounds.width + 160 }

    init(isPresented: Binding<Bool>, initialQueue: [Task]) {
        _isPresented = isPresented
        _state = StateObject(wrappedValue: PlanningModeState(initialQueue: initialQueue))
    }

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !showScheduler else { return }
                    dismiss()
                }

            PlanningSwipeArcView(
                direction: state.swipeArcState.direction,
                progress: state.swipeArcState.progress,
                opacity: state.swipeArcState.opacity
            )
                .ignoresSafeArea()

            GeometryReader { proxy in
                let isCompactHeight = proxy.size.height < 620

                VStack(spacing: 0) {
                    PlannerHeaderView(onDismiss: dismiss)

                    if state.isFinished {
                        PlanningFinishedStateView {
                            if state.isFinished { dismiss() }
                        }
                    } else {
                        PlanningProgressBadge(remaining: state.remaining)
                            .padding(.bottom, isCompactHeight ? 12 : 20)

                        Spacer(minLength: isCompactHeight ? 8 : 0)

                        cardSection

                        Spacer(minLength: isCompactHeight ? 8 : 0)

                        PlanningSwipeHintView()
                            .padding(.horizontal, 16)
                            .padding(.bottom, isCompactHeight ? 16 : 28)
                    }
                }
            }

            if showScheduler {
                PlanningScheduleOverlayView(
                    task: pendingTask,
                    notificationService: vm.notificationService,
                    calendarSyncService: vm.calendarSyncService,
                    dragState: scheduleDragState,
                    onSchedule: { task, date, time, duration, reminderEnabled, calendarSyncEnabled in
                        scheduleTask(
                            task,
                            on: date,
                            time: time,
                            duration: duration,
                            reminderEnabled: reminderEnabled,
                            calendarSyncEnabled: calendarSyncEnabled
                        )
                    },
                    onCancel: { cancelSchedule() }
                )
            }
        }
    }

    // MARK: - Card Section

    @ViewBuilder
    private var cardSection: some View {
        if !state.visibleTasks.isEmpty {
            PlanningCardStackView(
                tasks: state.visibleTasks,
                remaining: state.remaining,
                dragOffset: state.offset,
                isSwipeHandled: state.swipeHandled,
                lockedAxis: $state.lockedAxis,
                onDragBegan: state.showSwipeArcWithoutAnimation,
                onDragOffsetChange: state.setDragOffset,
                onDragEnded: handleSwipe,
                onSkip: skipCurrentTask,
                onDelete: deleteCurrentTask,
                onSchedule: openScheduler
            )
            .animation(.smoothSpring, value: state.visibleTasks.map(\.id))
        }
    }

    // MARK: - Swipe Handling

    private func handleSwipe(_ value: DragGesture.Value, task: Task) {
        guard !state.swipeHandled else { return }
        let tx = state.offset.width
        let ty = state.offset.height

        if tx > 90 && state.lockedAxis == .horizontal {
            withAnimation(.smoothSpring) { state.offset = .zero }
            openSchedulerFor(task)
        } else if tx < -90 && state.lockedAxis == .horizontal {
            animateCardOut(to: CGSize(width: -cardExitDistance, height: 0)) {
                state.removeCurrentTaskFromQueue()
            }
        } else if ty > 100 && state.lockedAxis == .vertical {
            animateCardOut(to: CGSize(width: 0, height: cardExitDistance)) {
                vm.delete(task)
                state.removeCurrentTaskFromQueue()
            }
        } else {
            withAnimation(.smoothSpring) { state.offset = .zero }
            state.fadeHighlightImmediately()
        }
    }

    // MARK: - Button Handlers

    private func skipCurrentTask() {
        guard !state.swipeHandled, state.currentTask != nil else { return }
        animateCardOut(to: CGSize(width: -cardExitDistance, height: 0)) {
            state.removeCurrentTaskFromQueue()
        }
    }

    private func deleteCurrentTask() {
        guard !state.swipeHandled, let task = state.currentTask else { return }
        animateCardOut(to: CGSize(width: 0, height: cardExitDistance)) {
            vm.delete(task)
            state.removeCurrentTaskFromQueue()
        }
    }

    private func openScheduler() {
        guard let task = state.currentTask else { return }
        openSchedulerFor(task)
    }

    private func openSchedulerFor(_ task: Task) {
        state.showActionHighlight(.right)
        state.fadeHighlightAfterDelay()
        pendingTask = task
        scheduleDragState.reset()
        withAnimation(.smoothSpring) { state.offset = .zero }
        withAnimation(.sheetSpring) { showScheduler = true }
    }

    // MARK: - Schedule Callbacks

    private func scheduleTask(
        _ task: Task,
        on date: Date,
        time: String? = nil,
        duration: Int16 = 0,
        reminderEnabled: Bool = false,
        calendarSyncEnabled: Bool = false
    ) {
        vm.scheduleFromInbox(task, date: date, time: time, duration: duration,
                             reminderEnabled: reminderEnabled, calendarSyncEnabled: calendarSyncEnabled)
        withAnimation(.smoothSpring) { state.removeCurrentTaskFromQueue() }
        withAnimation(.sheetSpring) { showScheduler = false }
        pendingTask = nil
    }

    private func cancelSchedule() {
        withAnimation(.sheetSpring) { showScheduler = false }
        pendingTask = nil
    }

    private func dismiss() {
        withAnimation(.sheetSpring) { isPresented = false }
    }

    private func animateCardOut(to targetOffset: CGSize, afterFlight updateQueue: @escaping () -> Void) {
        guard !state.swipeHandled else { return }
        state.swipeHandled = true
        state.showActionHighlight(for: targetOffset)
        withAnimation(.easeOut(duration: 0.22), completionCriteria: .logicallyComplete) {
            state.offset = targetOffset
        } completion: {
            state.finishCardExit(updateQueue)
            state.swipeHandled = false
            state.fadeHighlightAfterDelay()
        }
    }
}
