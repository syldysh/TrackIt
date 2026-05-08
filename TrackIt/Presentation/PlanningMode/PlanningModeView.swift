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
    let initialQueue: [Task]

    @State private var queue: [Task]? = nil
    @State private var offset: CGSize = .zero
    @State private var lockedAxis: PlanningSwipeAxis? = nil
    @State private var swipeHandled = false
    @State private var swipeArcIsFadingOut = false
    @State private var showScheduler = false
    @State private var pendingTask: Task? = nil
    @StateObject private var scheduleDragState = ModalDragState(dismissDistance: 100, predictedDismissDistance: 190)

    private var activeQueue: [Task] { queue ?? initialQueue }
    private var currentTask: Task? { activeQueue.first }
    private func ensureQueue() { if queue == nil { queue = initialQueue } }
    private var remaining: Int { activeQueue.count }
    private var isFinished: Bool { activeQueue.isEmpty }
    private var cardExitDistance: CGFloat { UIScreen.main.bounds.width + 160 }
    private var visibleTasks: [Task] { Array(activeQueue.prefix(3)) }
    private var swipeArcState: PlanningSwipeArcState {
        PlanningSwipeArcState(offset: offset, isFadingOut: swipeArcIsFadingOut)
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

            PlanningSwipeArcView(direction: swipeArcState.direction, progress: swipeArcState.progress)
                .ignoresSafeArea()

            GeometryReader { proxy in
                let isCompactHeight = proxy.size.height < 620

                VStack(spacing: 0) {
                    PlannerHeaderView(onDismiss: dismiss)

                    if isFinished {
                        PlanningFinishedStateView {
                            if isFinished { dismiss() }
                        }
                    } else {
                        PlanningProgressBadge(remaining: remaining)
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
        .onAppear { if queue == nil { queue = initialQueue } }
    }

    // MARK: - Card Section

    @ViewBuilder
    private var cardSection: some View {
        if !visibleTasks.isEmpty {
            PlanningCardStackView(
                tasks: visibleTasks,
                remaining: remaining,
                dragOffset: offset,
                isSwipeHandled: swipeHandled,
                lockedAxis: $lockedAxis,
                onDragBegan: showSwipeArcWithoutAnimation,
                onDragOffsetChange: setDragOffset,
                onDragEnded: handleSwipe,
                onSkip: skipCurrentTask,
                onDelete: deleteCurrentTask,
                onSchedule: openScheduler
            )
            .animation(.smoothSpring, value: visibleTasks.map(\.id))
        }
    }

    // MARK: - Swipe Handling

    private func handleSwipe(_ value: DragGesture.Value, task: Task) {
        guard !swipeHandled else { return }
        let tx = offset.width
        let ty = offset.height

        if tx > 90 && lockedAxis == .horizontal {
            withAnimation(.smoothSpring) { offset = .zero }
            openSchedulerFor(task)
        } else if tx < -90 && lockedAxis == .horizontal {
            animateCardOut(to: CGSize(width: -cardExitDistance, height: 0)) {
                removeCurrentTaskFromQueue()
            }
        } else if ty > 100 && lockedAxis == .vertical {
            animateCardOut(to: CGSize(width: 0, height: cardExitDistance)) {
                ensureQueue()
                vm.delete(task)
                removeCurrentTaskFromQueue()
            }
        } else {
            withAnimation(.smoothSpring) { offset = .zero }
        }
    }

    // MARK: - Button Handlers

    private func skipCurrentTask() {
        guard !swipeHandled, currentTask != nil else { return }
        animateCardOut(to: CGSize(width: -cardExitDistance, height: 0)) {
            removeCurrentTaskFromQueue()
        }
    }

    private func deleteCurrentTask() {
        guard !swipeHandled, let task = currentTask else { return }
        animateCardOut(to: CGSize(width: 0, height: cardExitDistance)) {
            ensureQueue()
            vm.delete(task)
            removeCurrentTaskFromQueue()
        }
    }

    private func openScheduler() {
        guard let task = currentTask else { return }
        openSchedulerFor(task)
    }

    private func openSchedulerFor(_ task: Task) {
        pendingTask = task
        scheduleDragState.reset()
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
        withAnimation(.smoothSpring) { removeCurrentTaskFromQueue() }
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

    private func removeCurrentTaskFromQueue() {
        ensureQueue()
        guard var queue, !queue.isEmpty else { return }
        queue.removeFirst()
        self.queue = queue
    }

    private func setDragOffset(_ newOffset: CGSize) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offset = newOffset
        }
    }

    private func showSwipeArcWithoutAnimation() {
        guard swipeArcIsFadingOut else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            swipeArcIsFadingOut = false
        }
    }

    private func animateCardOut(to targetOffset: CGSize, afterFlight updateQueue: @escaping () -> Void) {
        guard !swipeHandled else { return }
        swipeHandled = true
        withAnimation(.easeOut(duration: 0.18)) {
            swipeArcIsFadingOut = true
        }
        withAnimation(.easeOut(duration: 0.22)) {
            offset = targetOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            finishCardExit(updateQueue)
            swipeHandled = false
        }
    }

    private func finishCardExit(_ updateQueue: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            updateQueue()
            offset = .zero
            lockedAxis = nil
            swipeArcIsFadingOut = false
        }
    }
}
