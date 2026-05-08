//
//  PlanningCardStackView.swift
//  TrackIt
//
//  Стопка карточек задач в режиме планирования.
//

import SwiftUI

enum PlanningSwipeAxis {
    case horizontal
    case vertical
}

struct PlanningCardStackView: View {
    let tasks: [Task]
    let remaining: Int
    let dragOffset: CGSize
    let isSwipeHandled: Bool
    @Binding var lockedAxis: PlanningSwipeAxis?
    let onDragBegan: () -> Void
    let onDragOffsetChange: (CGSize) -> Void
    let onDragEnded: (DragGesture.Value, Task) -> Void
    let onSkip: () -> Void
    let onDelete: () -> Void
    let onSchedule: () -> Void

    private var visibleCards: [PlanningStackCard] {
        Array(tasks.prefix(3)).enumerated().map {
            PlanningStackCard(depth: $0.offset, task: $0.element)
        }
    }

    private var revealProgress: CGFloat {
        min((abs(dragOffset.width) + dragOffset.height) / 110, 1)
    }

    var body: some View {
        ZStack {
            ForEach(visibleCards.reversed()) { item in
                stackCard(item)
            }
        }
    }

    @ViewBuilder
    private func stackCard(_ item: PlanningStackCard) -> some View {
        let isActive = item.depth == 0
        let card = PlanningCardView(
            task: item.task,
            totalRemaining: remaining,
            offset: isActive ? dragOffset : .zero,
            onSkip: isActive ? onSkip : {},
            onDelete: isActive ? onDelete : {},
            onSchedule: isActive ? onSchedule : {}
        )

        if isActive {
            card
                .id(item.task.id)
                .zIndex(Double(10 - item.depth))
                .transition(activeTransition)
                .gesture(cardDragGesture(for: item.task))
        } else {
            let state = stackState(for: item.depth)
            card
                .id(item.task.id)
                .scaleEffect(state.scale)
                .offset(y: state.offsetY)
                .opacity(state.opacity)
                .zIndex(Double(10 - item.depth))
                .transition(.identity)
                .allowsHitTesting(false)
        }
    }

    private var activeTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 0.96))
                .combined(with: .offset(x: 0, y: 18)),
            removal: .opacity
        )
    }

    private func stackState(for depth: Int) -> PlanningStackCardState {
        let effectiveDepth = max(0, CGFloat(depth) - revealProgress)
        return PlanningStackCardState(
            scale: 1 - effectiveDepth * 0.04,
            offsetY: effectiveDepth * 16,
            opacity: 1 - Double(effectiveDepth) * 0.18
        )
    }

    private func cardDragGesture(for task: Task) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isSwipeHandled else { return }
                onDragBegan()
                if lockedAxis == nil && (abs(value.translation.width) > 10 || abs(value.translation.height) > 10) {
                    lockedAxis = abs(value.translation.width) >= abs(value.translation.height) ? .horizontal : .vertical
                }
                switch lockedAxis {
                case .horizontal:
                    onDragOffsetChange(CGSize(width: value.translation.width, height: 0))
                case .vertical:
                    onDragOffsetChange(CGSize(width: 0, height: max(value.translation.height, 0)))
                case nil:
                    break
                }
            }
            .onEnded { value in
                onDragEnded(value, task)
                lockedAxis = nil
            }
    }
}

private struct PlanningStackCard: Identifiable {
    let depth: Int
    let task: Task

    var id: UUID { task.id }
}

private struct PlanningStackCardState {
    let scale: CGFloat
    let offsetY: CGFloat
    let opacity: Double
}
