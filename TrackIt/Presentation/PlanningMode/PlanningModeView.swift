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
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var lockedAxis: SwipeAxis? = nil
    @State private var swipeHandled = false
    @State private var showScheduler = false
    @State private var pendingTask: Task? = nil
    @StateObject private var scheduleDragState = ModalDragState(dismissDistance: 100, predictedDismissDistance: 190)

    enum SwipeAxis { case horizontal, vertical }

    private var activeQueue: [Task] { queue ?? initialQueue }
    private var currentTask: Task? { activeQueue[safe: currentIndex] }
    private func ensureQueue() { if queue == nil { queue = initialQueue } }
    private var remaining: Int { max(0, activeQueue.count - currentIndex) }
    private var isFinished: Bool { activeQueue.isEmpty || currentIndex >= activeQueue.count }
    private var cardExitDistance: CGFloat { UIScreen.main.bounds.width + 160 }

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !showScheduler else { return }
                    dismiss()
                }

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

                        hintText
                            .padding(.horizontal, 16)
                            .padding(.bottom, isCompactHeight ? 16 : 28)
                    }
                }
            }

            if showScheduler {
                ModalDimBackground(dragState: scheduleDragState, baseOpacity: 0.32, onTap: cancelSchedule)
                    .transition(.opacity)
                    .zIndex(19)
            }

            if showScheduler, let task = pendingTask {
                SchedulePickerView(
                    task: task,
                    notificationService: vm.notificationService,
                    calendarSyncService: vm.calendarSyncService,
                    dragState: scheduleDragState,
                    onSchedule: { date, time, duration, reminderEnabled, calendarSyncEnabled in
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
                .transition(.move(edge: .bottom))
                .zIndex(20)
            }
        }
        .onAppear { if queue == nil { queue = initialQueue } }
    }

    // MARK: - Card Section

    @ViewBuilder
    private var cardSection: some View {
        if let task = currentTask {
            PlanningCardView(
                task: task,
                totalRemaining: remaining,
                offset: offset,
                onSkip: skipCurrentTask,
                onDelete: deleteCurrentTask,
                onSchedule: openScheduler
            )
            .id(task.id)
            .transition(cardTransition)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        guard !swipeHandled else { return }
                        if lockedAxis == nil && (abs(v.translation.width) > 10 || abs(v.translation.height) > 10) {
                            lockedAxis = abs(v.translation.width) >= abs(v.translation.height) ? .horizontal : .vertical
                        }
                        let nextOffset: CGSize
                        switch lockedAxis {
                        case .horizontal:
                            nextOffset = CGSize(width: v.translation.width, height: 0)
                        case .vertical:
                            nextOffset = CGSize(width: 0, height: max(v.translation.height, 0))
                        case nil:
                            nextOffset = offset
                        }
                        setDragOffset(nextOffset)
                    }
                    .onEnded { v in
                        handleSwipe(v, task: task)
                        lockedAxis = nil
                    }
            )
        }
    }

    private var cardTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 0.96))
                .combined(with: .offset(x: 0, y: 18)),
            removal: .opacity
        )
    }

    // MARK: - Hint Text

    private var hintText: some View {
        Text("Свайп: ← пропустить · → запланировать · ↓ удалить")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white.opacity(0.45))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
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
                currentIndex += 1
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
            currentIndex += 1
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
        vm.scheduleFromInbox(
            task,
            date: date,
            time: time,
            duration: duration,
            reminderEnabled: reminderEnabled,
            calendarSyncEnabled: calendarSyncEnabled
        )
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
        guard var queue, queue.indices.contains(currentIndex) else { return }
        queue.remove(at: currentIndex)
        if currentIndex >= queue.count && currentIndex > 0 {
            currentIndex = queue.count - 1
        }
        self.queue = queue
    }

    private func setDragOffset(_ newOffset: CGSize) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offset = newOffset
        }
    }

    private func resetOffsetWithoutAnimation() {
        setDragOffset(.zero)
    }

    private func animateCardOut(to targetOffset: CGSize, afterFlight updateQueue: @escaping () -> Void) {
        guard !swipeHandled else { return }
        swipeHandled = true
        withAnimation(.easeOut(duration: 0.22)) {
            offset = targetOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            resetOffsetWithoutAnimation()
            withAnimation(.smoothSpring) {
                updateQueue()
            }
            swipeHandled = false
        }
    }
}
