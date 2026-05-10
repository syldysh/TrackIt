//
//  ModalDragState.swift
//  TrackIt
//
//  Общая логика свайпа вниз для модальных окон.
//  Хранит смещение, затемнение фона и жест закрытия, чтобы не дублировать это в экранах.
//

import SwiftUI
import UIKit

final class ModalDragState: ObservableObject {
    @Published private(set) var offset: CGFloat = 0
    @Published private(set) var isDragging = false

    private let dismissDistance: CGFloat
    private let predictedDismissDistance: CGFloat
    private let dimFadeDistance: CGFloat
    private let dismissalOffset: CGFloat
    private var isDismissing = false

    private let settleAnimation = Animation.spring(response: 0.32, dampingFraction: 0.86)
    private let exitAnimationDuration: TimeInterval = 0.22

    init(
        dismissDistance: CGFloat = 120,
        predictedDismissDistance: CGFloat = 220,
        dimFadeDistance: CGFloat = 260,
        dismissalOffset: CGFloat = UIScreen.main.bounds.height * 0.65
    ) {
        self.dismissDistance = dismissDistance
        self.predictedDismissDistance = predictedDismissDistance
        self.dimFadeDistance = dimFadeDistance
        self.dismissalOffset = dismissalOffset
    }

    var dimOpacityMultiplier: CGFloat {
        1 - min(max(offset / dimFadeDistance, 0), 1)
    }

    func reset() {
        isDismissing = false
        setDragging(false)
        setOffset(0)
    }

    func dragGesture(onDismiss: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { [weak self] value in
                guard let self else { return }
                guard !isDismissing else { return }
                setDragging(true)
                setOffset(max(value.translation.height, 0))
            }
            .onEnded { [weak self] value in
                guard let self else { return }
                guard !isDismissing else { return }
                let distance = max(value.translation.height, 0)
                let predictedDistance = max(value.predictedEndTranslation.height, 0)

                if distance > dismissDistance || predictedDistance > predictedDismissDistance {
                    isDismissing = true
                    setDragging(false)
                    dismissKeyboard()
                    withAnimation(settleAnimation) {
                        self.offset = max(distance, self.dismissalOffset)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + exitAnimationDuration) {
                        onDismiss()
                    }
                } else {
                    setDragging(false)
                    withAnimation(settleAnimation) {
                        self.offset = 0
                    }
                }
            }
    }

    private func setOffset(_ value: CGFloat) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offset = value
        }
    }

    private func setDragging(_ value: Bool) {
        guard isDragging != value else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isDragging = value
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ModalDimBackground: View {
    @ObservedObject var dragState: ModalDragState
    let baseOpacity: CGFloat
    let onTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            Color.black.opacity(Double(baseOpacity))
        }
            .opacity(Double(dragState.dimOpacityMultiplier))
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .transaction { transaction in
                if dragState.isDragging {
                    transaction.animation = nil
                }
            }
    }
}

struct ModalDragHandle<Content: View>: View {
    @ObservedObject var dragState: ModalDragState
    let showsDragHandle: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        dragState: ModalDragState,
        showsDragHandle: Bool = true,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.dragState = dragState
        self.showsDragHandle = showsDragHandle
        self.onDismiss = onDismiss
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            if showsDragHandle {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
            }

            content()
        }
        .contentShape(Rectangle())
        .gesture(dragState.dragGesture(onDismiss: onDismiss))
    }
}

extension View {
    func modalDragOffset(_ dragState: ModalDragState) -> some View {
        offset(y: dragState.offset)
            .transaction { transaction in
                if dragState.isDragging {
                    transaction.animation = nil
                }
            }
    }
}
