//
//  PlanningModeState.swift
//  TrackIt
//
//  UI-состояние очереди и свайпа в режиме планирования.
//

import SwiftUI

@MainActor
final class PlanningModeState: ObservableObject {
    @Published private(set) var queue: [Task]
    @Published var offset: CGSize = .zero
    @Published var lockedAxis: PlanningSwipeAxis? = nil
    @Published var swipeHandled = false
    @Published private var highlightDirection: PlanningSwipeArcDirection = .none
    @Published private var highlightProgress: CGFloat = 0
    @Published private var highlightOpacity: Double = 0

    private static let highlightFadeDelay: TimeInterval = 0.12
    private static let highlightFadeDuration: TimeInterval = 0.18

    private var clearHighlightTask: DispatchWorkItem?
    private var highlightResetID = UUID()

    init(initialQueue: [Task]) {
        queue = initialQueue
    }

    var currentTask: Task? { queue.first }
    var remaining: Int { queue.count }
    var isFinished: Bool { queue.isEmpty }
    var visibleTasks: [Task] { Array(queue.prefix(3)) }
    var swipeArcState: PlanningSwipeArcState {
        PlanningSwipeArcState(
            direction: highlightDirection,
            progress: highlightProgress,
            opacity: highlightOpacity
        )
    }

    func removeCurrentTaskFromQueue() {
        guard !queue.isEmpty else { return }
        queue.removeFirst()
    }

    func setDragOffset(_ newOffset: CGSize) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offset = newOffset
        }
        showDragHighlight(for: newOffset)
    }

    func showSwipeArcWithoutAnimation() {
        clearHighlightTask?.cancel()
    }

    func finishCardExit(_ updateQueue: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            updateQueue()
            offset = .zero
            lockedAxis = nil
        }
    }

    func showActionHighlight(_ direction: PlanningSwipeArcDirection) {
        showHighlight(direction: direction, progress: 1)
    }

    func showActionHighlight(for targetOffset: CGSize) {
        let state = PlanningSwipeArcState(offset: targetOffset)
        showHighlight(direction: state.direction, progress: 1)
    }

    func fadeHighlightAfterDelay() {
        fadeHighlight(after: Self.highlightFadeDelay)
    }

    func fadeHighlightImmediately() {
        fadeHighlight(after: 0)
    }

    private func showDragHighlight(for offset: CGSize) {
        let state = PlanningSwipeArcState(offset: offset)
        guard state.direction != .none, state.progress > 0 else { return }
        showHighlight(direction: state.direction, progress: state.progress)
    }

    private func showHighlight(direction: PlanningSwipeArcDirection, progress: CGFloat) {
        clearHighlightTask?.cancel()
        highlightResetID = UUID()

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            highlightDirection = direction
            highlightProgress = min(max(progress, 0), 1)
            highlightOpacity = direction == .none ? 0 : 1
        }
    }

    private func fadeHighlight(after delay: TimeInterval) {
        clearHighlightTask?.cancel()
        let resetID = UUID()
        highlightResetID = resetID

        let workItem = DispatchWorkItem { [weak self] in
            _Concurrency.Task { @MainActor [weak self] in
                guard let self, self.highlightResetID == resetID else { return }
                withAnimation(.easeOut(duration: Self.highlightFadeDuration)) {
                    self.highlightOpacity = 0
                }
                self.clearHighlightAfterFade(resetID: resetID)
            }
        }

        clearHighlightTask = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func clearHighlightAfterFade(resetID: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.highlightFadeDuration) { [weak self] in
            _Concurrency.Task { @MainActor [weak self] in
                guard let self, self.highlightResetID == resetID else { return }
                self.clearHighlightWithoutAnimation()
            }
        }
    }

    private func clearHighlightWithoutAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            highlightDirection = .none
            highlightProgress = 0
            highlightOpacity = 0
        }
    }
}
