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
    @Published var swipeArcIsFadingOut = false

    init(initialQueue: [Task]) {
        queue = initialQueue
    }

    var currentTask: Task? { queue.first }
    var remaining: Int { queue.count }
    var isFinished: Bool { queue.isEmpty }
    var visibleTasks: [Task] { Array(queue.prefix(3)) }
    var swipeArcState: PlanningSwipeArcState {
        PlanningSwipeArcState(offset: offset, isFadingOut: swipeArcIsFadingOut)
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
    }

    func showSwipeArcWithoutAnimation() {
        guard swipeArcIsFadingOut else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            swipeArcIsFadingOut = false
        }
    }

    func finishCardExit(_ updateQueue: () -> Void) {
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
